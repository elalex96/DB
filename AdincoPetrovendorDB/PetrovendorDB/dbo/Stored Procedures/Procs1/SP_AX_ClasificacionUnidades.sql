-- =============================================
-- Author:		Daniel AC
-- Create date: 08/09/2020
-- Description: ACTUALIZACIÓN TIPO DE UNIDAD CARSO
-- =============================================
CREATE PROCEDURE [dbo].[SP_AX_ClasificacionUnidades] 
	@IdUnidad INT=0, 	
	@IdClasificacion INT=0,
	@Activo BIT, 
	@Accion NVARCHAR(100)='CONSULTA'

AS
BEGIN

	SET NOCOUNT ON;

	IF @Accion ='CONSULTA'
	BEGIN 
		--OBTENER TODAS LAS UNIDADES CON LA RELACIÓN A LA CLASIFICACIÓN ACTUAL (MATERIAL/SERVICIO)
		SELECT U.IdUnidad,U.Unidad,TM.IdTipoMaterialProcura AS IdClasificacion, AXC.Activo
		FROM dbo.PV_MM_MaterialUnidad U 
		LEFT JOIN  dbo.AX_UnidadClasificacion AXC
		ON AXC.IdUnidad = U.IdUnidad 
		LEFT JOIN dbo.MM_TipoMaterialProcura TM 
		ON AXC.IdClasificacion=TM.IdTipoMaterialProcura
	END 

	IF @Accion ='CONSULTA_TIPO_MATERIAL'
	BEGIN 
		SELECT IdTipoMaterialProcura, Descripcion 
		FROM dbo.MM_TipoMaterialProcura
	END 
	
	IF @ACCION='ACTUALIZA'
	BEGIN 
		--GUARDAR RELACIÓN DE LA UNIDAD CON LA CLASIFICACIÓN MATERIAL/SERVICIO 
		IF(SELECT COUNT(1) FROM dbo.AX_UnidadClasificacion WHERE IdUnidad=@IdUnidad)>0
		BEGIN 
			--YA EXISTE UNA RELACIÓN SOLO ACTUALIZAR EL REGISTRO
			UPDATE dbo.AX_UnidadClasificacion
			SET IdClasificacion=@IdClasificacion,
			ModificadoEl=GETDATE(),
			Activo=@Activo
			WHERE IdUnidad=@IdUnidad
			
			SELECT 'SUCCESS_ACTUALIZACIÓN'
		END 
		ELSE
        BEGIN 

			INSERT INTO dbo.AX_UnidadClasificacion
			(
			    IdUnidad,
			    IdClasificacion,
			    Activo,
			    CreadoEl			    
			)
			VALUES
			(   @IdUnidad,         -- IdUnidad - int
			    @IdClasificacion,         -- IdTipoMaterial - int
			    1,      -- Activo - bit
			    GETDATE()-- CreadoEl - datetime			   
			    )
			SELECT 'SUCCESS_NUEVO'
		END 
	END 

END

