using ParkAndGoBackend.Entity.Pagamento;
using ParkAndGoBackend.Entity.Reversa;
using ParkAndGoBackend.Entity.User;
using System.Data.Entity;

namespace ParkAndGoBackend.Entity
{
    public class ParkAndGoDbContext : DbContext
    {
        public ParkAndGoDbContext() : base("DefaultConnection")
        {
        }

        public DbSet<Estacionamento.Estacionamento> Estacionamentos { get; set; }
        public DbSet<Ticket> Ticket { get; set; }
        public DbSet<UserDevice> UserDevices { get; set; }
        public DbSet<DetalhePagamento> DetalhePagamentos { get; set; }
        public DbSet<SavedCreditCard> SavedCreditCards { get; set; }
    }
}
