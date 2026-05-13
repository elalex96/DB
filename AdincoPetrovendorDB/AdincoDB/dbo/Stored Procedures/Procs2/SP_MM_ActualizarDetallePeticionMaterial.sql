-- =============================================
-- Author:		Abel Rivera
-- Create date: 04-01-17
-- Description:	 Actualiza los valores de la peticón de Oferta Detalle por Material, Calcula el IVA 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarDetallePeticionMaterial] 
	-- Add the parameters for the stored procedure here

@IdPeticionOfertaDetalle  INT,
@PrecioUnitario           FLOAT,
@Disponibilidad           INT,
@IdMoneda                 INT,
@ComentarioSubcontratista NVARCHAR(MAX),
@IdUsuario                INT,
	----------------------
@IVA_Porcentaje           FLOAT,
    --@PrecioMasIva2 float = 0,
@PrecioMasIva             FLOAT,
@IdPeticionOferta         INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @CantidadIVa FLOAT= (@PrecioUnitario * @IVA_Porcentaje) / 100;
         DECLARE @PrecioMasIvaParam FLOAT= (@PrecioUnitario + @CantidadIVa);
         DECLARE @PrecioUnitario2 FLOAT= (@PrecioMasIva * 100) / (@IVA_Porcentaje + 100);
         DECLARE @CantidadIva2 FLOAT= (@PrecioUnitario2 * @IVA_Porcentaje) / 100;
         IF @PrecioUnitario = 0
             BEGIN
                 UPDATE [dbo].[MM_PeticionOfertaDetalle]
                   SET
                       [PrecioUnitario] = CAST(@PrecioUnitario2 AS NUMERIC(18, 2)),
                       [ComentarioSubcontratista] = @ComentarioSubcontratista,
                       [ModificadoPor] = @IdUsuario,
                       [ModificadoEl] = GETDATE(),
                       [IdMoneda] = @IdMoneda,
                       [Disponibilidad] = @Disponibilidad,
                       [Cotizado] = 1,
                       IVA_Porcentaje = @IVA_Porcentaje,
                       CantidadIVa = @CantidadIva2,
                       PrecioMasIVA = @PrecioMasIva
                 WHERE [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle;
         END;
             ELSE
         IF @PrecioMasIva = 0
             BEGIN
                 UPDATE [dbo].[MM_PeticionOfertaDetalle]
                   SET
                       [PrecioUnitario] = @PrecioUnitario,
                       [ComentarioSubcontratista] = @ComentarioSubcontratista,
                       [ModificadoPor] = @IdUsuario,
                       [ModificadoEl] = GETDATE(),
                       [IdMoneda] = @IdMoneda,
                       [Disponibilidad] = @Disponibilidad,
                       [Cotizado] = 1,
                       [IVA_Porcentaje] = @IVA_Porcentaje,
                       [CantidadIVa] = @CantidadIVa,
                       PrecioMasIVA = CAST(@PrecioMasIvaParam AS NUMERIC(18, 2))
                 WHERE [IdPeticionOfertaDetalle] = @IdPeticionOfertaDetalle;
         END;


	---- Actualizar Estatus de la PeticionOferta Si todas las Peticiones --- 

         DECLARE @NUM_PeticionesDetalle INT=
         (
             SELECT COUNT(IdPeticionOfertaDetalle)
             FROM MM_PeticionOfertaDetalle
             WHERE IdPeticionOferta = @IdPeticionOferta
         );
         DECLARE @NUM_PeticionesDetalleCotizadas INT=
         (
             SELECT COUNT(IdPeticionOfertaDetalle)
             FROM MM_PeticionOfertaDetalle
             WHERE IdPeticionOferta = @IdPeticionOferta
                   AND Cotizado = 1
         );
         IF @NUM_PeticionesDetalle = @NUM_PeticionesDetalleCotizadas
             BEGIN
                 UPDATE MM_PeticionOferta
                   SET
                       Cotizado = 1
                 WHERE IdPeticionOferta = @IdPeticionOferta;
         END;
     END;
