/*
--------------------------------------------------------------------------------------------------------------
-> Name: mem_pool.h
-> Authors: João P. C. Fogetti, Luiz H. A. Santos, Pedro A. W. Dian, Rodrigo M. Franca, Sergio R. Augusto.
-> Date: 10-10-2025
-> Description: library for defining memory pools and buffers for transfering data internally and externally within tasks.
--------------------------------------------------------------------------------------------------------------
*/
#include <stdlib.h>
#include "system.h"
#include "alt_types.h"

/* ------------------------------------------------------------------------------------------------------------- */
// General defines and types

#define MAX_NUM_STRUCTURES 1024
#define MAX_NUM_POOLS      16

// Struct for mem pool with determined size
typedef struct mem_pool_unit{

    size_t  sStructureSize;     // Size for a single structure into the pool
    alt_u32 u32NumStructures;   // Number of structures implemented by the pool
    void*   pMemPoolInitOffset; // Offset for the mem_pool

    alt_u8  u8StructureIsAlloc[MAX_NUM_STRUCTURES];     // Indicates wether a structure has been allocated
    // SemaphoreHandle_t oMemPoolLock; // Enables task-safe access of the mem_pool
    
} mem_pool_unit;

// Struct for managing different mem pools
typedef struct mem_pool_gen{

    mem_pool_unit oMemPoolUnits[MAX_NUM_POOLS];
    alt_u8        u8MemPoolIsAlloc[MAX_NUM_POOLS];

} mem_pool_gen;

/* ------------------------------------------------------------------------------------------------------------- */


/* ------------------------------------------------------------------------------------------------------------- */
// Function prototypes

// Init mem_pool units and manager
void mem_pool_init_unit(mem_pool_unit* pool, void* mem_base,
                        size_t struct_size, alt_u32 num_structures, alt_u8 task_safe);

void mem_pool_init_manager(mem_pool_gen* manager);

// Alloc and free to specific mem_pools initializedd
void* mem_pool_alloc_task_safe(mem_pool_unit* pool);
void* mem_pool_alloc_non_task_safe(mem_pool_unit* pool);

void  mem_pool_free_task_safe(mem_pool_unit* pool, void* ptr);
void  mem_pool_free_non_task_safe(mem_pool_unit* pool, void* ptr);

// Gen alloc and free to all mem_pools initialized
void* mem_pool_gen_alloc(mem_pool_gen* manager, size_t size);
void  mem_pool_gen_free(mem_pool_gen* manager, void* ptr, size_t size);

/* ------------------------------------------------------------------------------------------------------------- */
