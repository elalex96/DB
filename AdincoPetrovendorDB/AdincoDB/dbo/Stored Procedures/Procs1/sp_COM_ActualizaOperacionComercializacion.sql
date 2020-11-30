CREATE PROCEDURE [dbo].[sp_COM_ActualizaOperacionComercializacion]
-- Add the parameters for the stored procedure here
@IdOperacionComercializacion   INT, 
@IdContrato                    INT, 
@MesReporte                    DATE, 
@FechaTransaccion              DATE, 
@IdTipoHidrocarburo            INT, 
@VolumenVendido                FLOAT, 
@PrecioVentaUnitario           MONEY, 
@CostoUnitarioComercializacion MONEY, 
@PrecioPuntoMedicion           MONEY, 
@IdFactura                     INT, 
@NumeroFolioPedimento          NVARCHAR(MAX), 
@EPT                           BIT, 
@OperacionBajoReglasMercado    BIT, 
@ClasificacionDocumentoSoporte INT, 
@IdUsuario                     INT, 
@PenaEconomica                 FLOAT         = 0
AS
     BEGIN
         --
         SET NOCOUNT ON;
         DECLARE @InsertedRecord INT;
         UPDATE [COM_OperacionComercializacion]
           SET 
               [MesReporte] = @MesReporte, 
               [FechaTransaccion] = @FechaTransaccion, 
               [IdTipoHidrocarburo] = @IdTipoHidrocarburo, 
               [VolumenVendido] = @VolumenVendido, 
               [PrecioVentaUnitario] = @PrecioVentaUnitario, 
               [CostoUnitarioComercializacion] = @CostoUnitarioComercializacion, 
               [PrecioPuntoMedicion] = @PrecioPuntoMedicion, 
               [IdFactura] = @IdFactura, 
               [NumeroFolioPedimento] = @NumeroFolioPedimento, 
               [EPT] = @EPT, 
               [OperacionBajoReglasMercado] = @OperacionBajoReglasMercado, 
               [ClasificacionDocumentoSoporte] = @ClasificacionDocumentoSoporte, 
               [CreadoPor] = @IdUsuario, 
               [CreadoEl] = GETDATE(), 
               [PenaEconomica] = @PenaEconomica
         WHERE IdOperacionComercializacion = @IdOperacionComercializacion;
     END;