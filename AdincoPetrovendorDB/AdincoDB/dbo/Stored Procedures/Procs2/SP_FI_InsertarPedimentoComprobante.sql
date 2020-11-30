-- =============================================
-- Author:		Manuel CD
-- Create date: 04-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_InsertarPedimentoComprobante] 
	-- Add the parameters for the stored procedure here
@IdContrato                 INT,
@NumeroPedimento            NVARCHAR(MAX),
@ClavePedimento             INT,
@FolioComprobante           NVARCHAR(MAX),
@FechaPago                  DATE,
@Regimen                    NVARCHAR(MAX),
@AduanaES                   NVARCHAR(MAX),
@IdSubcontratistaExportador INT,
@IdMoneda                   INT,
@AcuseElectronico           NVARCHAR(MAX),
@DescripcionMercancia       NVARCHAR(MAX),
@SubTotal                   MONEY,
@IdUsuario                  INT,
@CvTipoDoc                  INT,
@DocumentoPDF               IMAGE,
@IdFiscal                   NVARCHAR(50),
@RazonSocial                NVARCHAR(MAX),
@ImporteInco                MONEY,
@CuentaBancaria				NVARCHAR(500)=''
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;
             DECLARE @idped INT;
             DECLARE @IdSubcontratistaImportador INT;
	    
	    /*PEDIMENTO*/

--Obtener proveedor importador
             SELECT @IdSubcontratistaImportador = CC.IdProveedor
             FROM CO_Contrato C
                  JOIN CO_Contratista CC ON C.IdContratista = CC.IdContratista
             WHERE C.IdContrato = @IdContrato;
		   --
             BEGIN
                 INSERT INTO [dbo].[FI_PedimentoComprobante]
([IdContrato],
 [NumeroPedimento],
 [ClavePedimento],
 [FolioComprobante],
 [FechaPago],
 [Regimen],
 [IdSubcontratistaImportador],
 [AduanaES],
 [IdSubcontratistaExportador],
 [IdMoneda],
 [AcuseElectronico],
 [CvTipoDocFacturacion],
 [CreadoPor],
 [CreadoEn],
 [IdFiscalP],
 [RazonSocialP],
 CuentaBancaria
)
                 VALUES
(@IdContrato,
 @NumeroPedimento,
 @ClavePedimento,
 @FolioComprobante,
 @FechaPago,
 @Regimen,
 @IdSubcontratistaImportador,
 @AduanaES,
 @IdSubcontratistaExportador,
 @IdMoneda,
 @AcuseElectronico,
 @CvTipoDoc,
 @IdUsuario,
 GETDATE(),
 @IdFiscal,
 @RazonSocial,
 @CuentaBancaria
);
             END;
             SET @idped = @@IDENTITY;
             --
             BEGIN
                 INSERT INTO [dbo].[FI_PedimentoComprobanteDetalle]
([IdPedimentoComprobante],
 [DescripcionMercancia],
 [PrecioUnitario],
 [CreadoPor],
 [CreadoEn],
 [ImporteTotal]
)
                 VALUES
(@idped,
 @DescripcionMercancia,
 @SubTotal,
 @IdUsuario,
 GETDATE(),
 @ImporteInco
);
             END;
             --
             BEGIN
                 INSERT INTO [dbo].[FI_Documento]
([IdTipoDocumento],
 [IdPedimentoComprobante],
 [NombreExtensionArchivo],
 [IdUsuario],
 [FechaCarga],
 [IsEliminado],
 [DocumentoByte]
)
                 VALUES
(4,
 @idped,
 CONCAT('PI_', @idped, '.pdf'),
 @IdUsuario,
 GETDATE(),
 0,
 @DocumentoPDF
);
             END;
             IF @@ERROR <> 0
                 SELECT 'false' AS msj;
                 ELSE
             SELECT 'true' AS msj,
                    @idped;
         END;
