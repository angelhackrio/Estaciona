using JetBrains.Annotations;
using ParkAndGoBackend.Services.Payment.Model;

namespace ParkAndGoBackend.Services.Payment
{
    public interface IPaymentService
    {
        [NotNull]
        PaymentResult PayWithCreditCard([NotNull] BillingWithCreditCardBase billingData);
    }
}