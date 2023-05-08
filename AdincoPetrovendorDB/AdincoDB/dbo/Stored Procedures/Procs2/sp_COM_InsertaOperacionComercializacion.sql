CREATE PROCEDURE [dbo].[sp_COM_InsertaOperacionComercializacion]
-- Add the parameters for the stored procedure here
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
         -- =============================================
         -- Author:		Miguel Gomez
         -- Create date: 2017-01-01
         -- Description:	Inserta una operacion de comercializacion
         -- =============================================
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @InsertedRecord INT;
         -- Insert statements for procedure here
         INSERT INTO [dbo].[COM_OperacionComercializacion]
         ([IdContrato], 
          [MesReporte], 
          [FechaTransaccion], 
          [IdTipoHidrocarburo], 
          [VolumenVendido], 
          [PrecioVentaUnitario], 
          [CostoUnitarioComercializacion], 
          [PrecioPuntoMedicion], 
          [IdFactura], 
          [NumeroFolioPedimento], 
          [EPT], 
          [OperacionBajoReglasMercado], 
          [ClasificacionDocumentoSoporte], 
          [CreadoPor], 
          [CreadoEl], 
          [Activo], 
          [PenaEconomica]
         )
         VALUES
         (@IdContrato, 
          @MesReporte, 
          @FechaTransaccion, 
          @IdTipoHidrocarburo, 
          @VolumenVendido, 
          @PrecioVentaUnitario, 
          @CostoUnitarioComercializacion, 
          @PrecioPuntoMedicion, 
          @IdFactura, 
          @NumeroFolioPedimento, 
          @EPT, 
          @OperacionBajoReglasMercado, 
          @ClasificacionDocumentoSoporte, 
          @IdUsuario, 
          GETDATE(), 
          1, 
          @PenaEconomica
         );
         SELECT @InsertedRecord AS INSERTADO, 
                CONCAT('La operación de comercialización se ha guardado exitosamente con el número de transacción (TR) ', @InsertedRecord) AS MSG;
     END;