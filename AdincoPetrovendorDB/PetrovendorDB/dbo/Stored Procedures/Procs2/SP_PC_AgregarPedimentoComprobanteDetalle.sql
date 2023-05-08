-- =============================================
-- Author:		DANIEL AC
-- Create date: 27-03-18
-- Description:	agregar Detalle de pedimento comprobante 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_AgregarPedimentoComprobanteDetalle] 
	-- Add the parameters for the stored procedure here

@IdProveedor        INT,
@IdContrato    INT,
@IdUsuario     INT,
@IdPedimentoComprobante INT,
@IdAceptacionPedido INT,
@PrecioUnitario FLOAT,
@DescripcionMercancia NVARCHAR(max),
@IdUnidadMedida INT,
@NumeroSerieMercancia NVARCHAR(200),
@Cantidad FLOAT,
@ImporteTotal FLOAT,
@IdDocFacturaActivo INT 

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		   DECLARE @TOTAL FLOAT 
		   IF @IdUnidadMedida IS NOT NULL AND @DescripcionMercancia IS NOT NULL AND @Cantidad IS NOT NULL
		   BEGIN

		   IF @IdDocFacturaActivo = 2 /*CV_TipoDoc CTE EN UTL --> PEDIMENTO CALCULAR EL IMPORTE TOTAL*/
			BEGIN 
				SET @ImporteTotal = @Cantidad * @PrecioUnitario
			END 


		   INSERT INTO dbo.FI_PedimentoComprobanteDetalle
		   (
		       IdPedimentoComprobante,
		       IdUnidadMedida,
		       NumeroSerieMercancia,
		       DescripcionMercancia,		      
		       PrecioUnitario,
		       Cantidad,
		       ImporteTotal,
		       CreadoPor,
		       CreadoEn,		      
		       IsEliminado,
		       IsActivo,
		       IsBorrador,		     
		       IdMaterialImportado,
		       IdAceptacionPedidoDetalle,
			   IdAceptacionPedido
		   )
		   VALUES
		   (   @IdPedimentoComprobante,         -- IdPedimentoComprobante - int
		       @IdUnidadMedida,         -- IdUnidadMedida - int
		       @NumeroSerieMercancia,       -- NumeroSerieMercancia - nvarchar(50)
		       @DescripcionMercancia,       -- DescripcionMercancia - nvarchar(max)		      
		       @PrecioUnitario,      -- PrecioUnitario - money
		       @Cantidad,      -- Cantidad - numeric(15, 0)
		       @ImporteTotal,      -- ImporteTotal - money
		       @IdUsuario,         -- CreadoPor - int
		       GETDATE(), -- CreadoEn - datetime		     
		       0,      -- IsEliminado - bit
		       1,      -- IsActivo - bit
		       1,      -- IsBorrador - bit		   
		       NULL,         -- IdMaterialImportado - int
		       NULL ,        -- IdAceptacionPedidoDetalle - int
			   @IdAceptacionPedido
		       )
           END 

		   SELECT 'SUCCESS' 
     END;

	