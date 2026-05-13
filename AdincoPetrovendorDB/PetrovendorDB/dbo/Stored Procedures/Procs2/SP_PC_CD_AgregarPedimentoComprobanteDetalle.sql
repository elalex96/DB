-- =============================================
-- Author:		DANIEL AC
-- Create date: 17-04-18
-- Description:	agregar Detalle de pedimento comprobante 
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_CD_AgregarPedimentoComprobanteDetalle] 
	-- Add the parameters for the stored procedure here

@IdProveedor        INT,
@IdContrato    INT,
@IdUsuario     INT,
@IdPedimentoComprobante INT, 
@PrecioUnitario DECIMAL(16,4),
@DescripcionMercancia NVARCHAR(max),
@IdUnidadMedida INT,
@NumeroSerieMercancia NVARCHAR(200),
@Cantidad DECIMAL(16,4),
@ImporteTotal DECIMAL(16,4),
@IdDocFacturaActivo INT 

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

		  

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
				   IsBorrador   
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
				   1        -- IsBorrador - bit	  
				   )
          

		   SELECT 'SUCCESS',@@IDENTITY AS IdPedimentoComprobanteDetalle

     END;

	