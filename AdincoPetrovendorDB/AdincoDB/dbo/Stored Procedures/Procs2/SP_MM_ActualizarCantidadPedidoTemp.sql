-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 04-01-17
-- Description:	 Actualiza los valores de la peticón de Oferte Detalle por Material
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarCantidadPedidoTemp] 
	-- Add the parameters for the stored procedure here

@IdPeticionOfertaDetalle INT,
@AddCantidadTemp         INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @PRECIO_UNITARIO FLOAT;
         DECLARE @PRECIO_TOTAL FLOAT;
         SET @PRECIO_UNITARIO =
         (
             SELECT PrecioMasIVA
             FROM MM_PeticionOfertaDetalle
             WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle
         );
         SET @PRECIO_TOTAL = @PRECIO_UNITARIO * @AddCantidadTemp;
         UPDATE [dbo].[MM_PeticionOfertaDetalle]
           SET
               AddCantidadTemp = @AddCantidadTemp,
               AddSubTotalTemp = @PRECIO_TOTAL,
               AddValidado = 1
         WHERE IdPeticionOfertaDetalle = @IdPeticionOfertaDetalle;
     END;
