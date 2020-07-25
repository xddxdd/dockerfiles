#if defined(STEP_COUNTER)
#defeval STEP_COUNTER #eval STEP_COUNTER + 1
#else
#defeval STEP_COUNTER 0
#endif

#define CONCAT #1#2
#define STEP CONCAT(step_,STEP_COUNTER)