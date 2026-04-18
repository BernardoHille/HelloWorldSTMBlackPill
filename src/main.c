#include <stdint.h>

#define RCC_BASE       0x40023800UL
#define GPIOC_BASE     0x40020800UL

#define RCC_AHB1ENR    (*(volatile uint32_t *)(RCC_BASE + 0x30U))
#define GPIOC_MODER    (*(volatile uint32_t *)(GPIOC_BASE + 0x00U))
#define GPIOC_OTYPER   (*(volatile uint32_t *)(GPIOC_BASE + 0x04U))
#define GPIOC_OSPEEDR  (*(volatile uint32_t *)(GPIOC_BASE + 0x08U))
#define GPIOC_PUPDR    (*(volatile uint32_t *)(GPIOC_BASE + 0x0CU))
#define GPIOC_BSRR     (*(volatile uint32_t *)(GPIOC_BASE + 0x18U))

#define RCC_AHB1ENR_GPIOCEN  (1UL << 2)
#define LED_PIN              13U
#define LED_MASK             (1UL << LED_PIN)

static void delay(volatile uint32_t count)
{
    while (count--) {
        __asm volatile ("nop");
    }
}

int main(void)
{
    /* The Black Pill user LED is on PC13 and is active low. */
    RCC_AHB1ENR |= RCC_AHB1ENR_GPIOCEN;

    GPIOC_MODER &= ~(0x3UL << (LED_PIN * 2U));
    GPIOC_MODER |=  (0x1UL << (LED_PIN * 2U));
    GPIOC_OTYPER &= ~LED_MASK;
    GPIOC_OSPEEDR &= ~(0x3UL << (LED_PIN * 2U));
    GPIOC_PUPDR &= ~(0x3UL << (LED_PIN * 2U));

    /* Start with the LED off. */
    GPIOC_BSRR = LED_MASK;

    while (1) {
        GPIOC_BSRR = (LED_MASK << 16U);  /* LED on  */
        delay(800000UL);

        GPIOC_BSRR = LED_MASK;           /* LED off */
        delay(800000UL);
    }
}
