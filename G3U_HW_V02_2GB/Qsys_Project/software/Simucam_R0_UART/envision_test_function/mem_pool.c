/*
--------------------------------------------------------------------------------------------------------------
-> Name: mem_pool.c
-> Authors: João P. C. Fogetti, Luiz H. A. Santos, Pedro A. W. Dian, Rodrigo M. Franca, Sergio R. Augusto.
-> Date: 10-10-2025
-> Description: library for defining memory pools and buffers for transfering data internally and externally within tasks.
--------------------------------------------------------------------------------------------------------------
*/

#include "mem_pool.h"
#include <string.h>

//----------------------------------------------------
// Inicializa uma unidade de pool
//----------------------------------------------------
void mem_pool_init_unit(mem_pool_unit* pool, void* mem_base,
                        size_t struct_size, alt_u32 num_structures,
                        alt_u8 task_safe)
{
    pool->sStructureSize   = struct_size;
    pool->u32NumStructures = num_structures;
    pool->pMemPoolInitOffset = mem_base;

    // Zera o mapa de alocação
    memset(pool->u8StructureIsAlloc, 0, MAX_NUM_STRUCTURES);

    // Cria mutex se for task-safe
    // pool->oMemPoolLock = (task_safe) ? xSemaphoreCreateMutex() : NULL;
}

//----------------------------------------------------
// Inicializa o gerenciador de pools
//----------------------------------------------------
void mem_pool_init_manager(mem_pool_gen* manager)
{
    memset(manager, 0, sizeof(mem_pool_gen));
}

//----------------------------------------------------
// Aloca estrutura (não task-safe)
//----------------------------------------------------
void* mem_pool_alloc_non_task_safe(mem_pool_unit* pool)
{
    for (alt_u32 i = 0; i < pool->u32NumStructures; i++) {
        if (pool->u8StructureIsAlloc[i] == 0) {
            pool->u8StructureIsAlloc[i] = 1;
            return (alt_u8*)pool->pMemPoolInitOffset + (i * pool->sStructureSize);
        }
    }
    return NULL; // pool cheio
}

//----------------------------------------------------
// Libera estrutura (não task-safe)
//----------------------------------------------------
void mem_pool_free_non_task_safe(mem_pool_unit* pool, void* ptr)
{
	alt_u8* base = (alt_u8*)pool->pMemPoolInitOffset;
	alt_u8* target = (alt_u8*)ptr;
	alt_u8* offset = target - base;

    alt_u32 index = (alt_u32) ((alt_u32) offset / ((alt_u32) pool->sStructureSize));

    if (index < pool->u32NumStructures) {
        pool->u8StructureIsAlloc[index] = 0;
    }
}

//----------------------------------------------------
// Aloca estrutura (task-safe)
//----------------------------------------------------
void* mem_pool_alloc_task_safe(mem_pool_unit* pool)
{
    void* ptr = NULL;

   // if (pool->oMemPoolLock)
   //     xSemaphoreTake(pool->oMemPoolLock, portMAX_DELAY);

    ptr = mem_pool_alloc_non_task_safe(pool);

    // if (pool->oMemPoolLock)
    //    xSemaphoreGive(pool->oMemPoolLock);

    return ptr;
}

//----------------------------------------------------
// Libera estrutura (task-safe)
//----------------------------------------------------
void mem_pool_free_task_safe(mem_pool_unit* pool, void* ptr)
{
   //  if (pool->oMemPoolLock)
   //     xSemaphoreTake(pool->oMemPoolLock, portMAX_DELAY);

    mem_pool_free_non_task_safe(pool, ptr);

    // if (pool->oMemPoolLock)
    //    xSemaphoreGive(pool->oMemPoolLock);
}

//----------------------------------------------------
// Alocação via gerenciador (com size)
//----------------------------------------------------
void* mem_pool_gen_alloc(mem_pool_gen* manager, size_t size)
{
    // Itera do menor para o maior pool
    for (alt_u8 i = 0; i < MAX_NUM_POOLS; i++) {
        if (manager->u8MemPoolIsAlloc[i]) {
            mem_pool_unit* pool = &manager->oMemPoolUnits[i];

            // Primeiro pool suficientemente grande
            if (pool->sStructureSize >= size) {
                return mem_pool_alloc_task_safe(pool);
            }
        }
    }
    return NULL; // Nenhum pool compatível
}


//----------------------------------------------------
// Liberação via gerenciador (com size conhecido)
//----------------------------------------------------
void mem_pool_gen_free(mem_pool_gen* manager, void* ptr, size_t size)
{
    // Itera até encontrar o pool que cobre o tamanho
    for (alt_u8 i = 0; i < MAX_NUM_POOLS; i++) {
        if (manager->u8MemPoolIsAlloc[i]) {
            mem_pool_unit* pool = &manager->oMemPoolUnits[i];

            // Como os pools são ordenados por tamanho, paramos ao passar o limite
            if (pool->sStructureSize >= size) {
            	alt_u32 base = (alt_u32)pool->pMemPoolInitOffset;
            	alt_u32 end  = base + (pool->sStructureSize * pool->u32NumStructures);
                if ((alt_u32)ptr >= base && (alt_u32)ptr < end) {
                    mem_pool_free_task_safe(pool, ptr);
                    return;
                }
            }
        }
    }
}

