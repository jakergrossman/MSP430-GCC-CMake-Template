/*
 * Simple Pulsing LED
 *
 * Description:
 * Pulse the green LED on the MSP-EXP430F5529LP development board.
 */

#include <msp430.h>

#ifdef __cplusplus
extern "C" {
#endif

#define TIMER_PERIOD_TICKS 512

static void init_ports();
static void init_timer();

int main(void)
{
    /* Disable watchdog timer */
    WDTCTL = WDTPW | WDTHOLD;

    init_ports();
    init_timer();

    __low_power_mode_3();
    __no_operation();
}

static void init_ports(void)
{
    /* Setup port mapping controller:
     * P4.7 -> TB0 CCR1 compare output
     */
    PMAPKEYID = PMAPKEY;
    P4MAP7 = PM_TB0CCR1A;
    /* lock port map controller */
    PMAPKEYID = 0;

    P4DIR |= BIT7;
    P4SEL |= BIT7;
}

static void init_timer(void)
{
    /* Setup timer:
     * TB0, sourced from SMCLK
     * Up Mode
     * Reset/Set (PWM with period CCR0, duty cycle CCR1/CCR0)
     */
    TB0CTL = TBSSEL__SMCLK | TBCLR;
    TB0CCR0 = TIMER_PERIOD_TICKS;
    TB0CCR1 = TIMER_PERIOD_TICKS;
    TB0CCTL1 |= OUTMOD_7;

    TB0CTL |= TBCLR | MC__UP;
    TB0CCTL1 |= CCIE;
}

void __attribute__((interrupt(TIMER0_B1_VECTOR))) TIMER_B0_ISR(void)
{
    static int direction = 1;
    switch (TBIV)
    {
        case TB0IV_TBCCR1:
            TB0CTL &= ~(MC_1 | MC_2 | MC_3);

            if ((TB0CCR1 == TIMER_PERIOD_TICKS) || (TB0CCR1 == 0))
            {
                direction *= -1;
            }

            TB0CCR1 += direction;

            TB0CTL |= MC_1;
            break;
    }
}

#ifdef __cplusplus
}
#endif
