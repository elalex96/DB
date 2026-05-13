-- =============================================
-- Author:		Abel Rivera
-- Create date: 04-01-17 Actualización 10/7/2017
-- Description:	 Actualiza los valores de la peticón de Oferta Detalle por Material, Calcula el IVA 
-- Author:		DAC
-- Create date: 08/08/2017
-- Description:	 Comente la actualización automatica de la petición de oferta 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarDetallePeticionMaterial] 
	-- Add the parameters for the stored procedure here

	@IdPeticionOfertaDetalle int,
	@PrecioUnitario float,
	@Disponibilidad int, 
	@IdMoneda int,
	@ComentarioSubcontratista nvarchar(max),
	@IdUsuario int,
	----------------------
	@IdMaterialVendedor int,
	@IdPeticionOferta int,
	@FechaVigencia datetime, 
	@IdProveedorActual INT,
	@NoCotizar BIT
	


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	IF ISNULL(@NoCotizar, 0) = 0
	BEGIN	
	declare  @Subtotal float = @PrecioUnitario * @Disponibilidad

			UPDATE [dbo].[MM_PeticionOfertaDetalle]
			SET [PrecioUnitario]= CAST(@PrecioUnitario AS NUMERIC(18,2)),
				[ComentarioSubcontratista] = @ComentarioSubcontratista,
				[ModificadoPor] = @IdUsuario,
				[ModificadoEl]  = GETDATE(),
				[IdMoneda] = @IdMoneda,
				[Disponibilidad]= @Disponibilidad,
				[Cotizado] = 1 ,
				[SubTotal] = @Subtotal,
                [FechaVigencia] = @FechaVigencia,
				[ModificadoProveedorPor] =   @IdProveedorActual,
				[IdMaterialVendedor] = @IdMaterialVendedor,
				[NoCotizar] = @noCotizar			
			WHERE [IdPeticionOfertaDetalle]=@IdPeticionOfertaDetalle
		SELECT 'SUCCESS'
	END 
	ELSE	
		BEGIN
			UPDATE [dbo].[MM_PeticionOfertaDetalle]
			SET [NoCotizar] = @noCotizar,
				[PrecioUnitario]= NULL,
				[ComentarioSubcontratista] = NULL,
				[ModificadoPor] = @IdUsuario,
				[ModificadoEl]  = GETDATE(),
				[IdMoneda] = NULL,
				[Disponibilidad]= NULL,
				[Cotizado] = 0,
				[SubTotal] = NULL,
                [FechaVigencia] = NULL,
				[ModificadoProveedorPor] =   @IdProveedorActual,
				[IdMaterialVendedor] = NULL
			WHERE [IdPeticionOfertaDetalle]=@IdPeticionOfertaDetalle	

			SELECT 'SUCCESS'
		END	

END




