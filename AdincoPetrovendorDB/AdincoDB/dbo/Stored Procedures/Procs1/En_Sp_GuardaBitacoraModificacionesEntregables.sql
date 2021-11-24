--=============================================
-- CREADO POR: LUIS DAVID
-- FECHA MODIFICACIÓN: 22/11/2021
-- DESCRIPCIÓN: SE CONTEMPLA EL BIT AWARENESS
--=============================================
GO
DROP PROCEDURE IF EXISTS En_Sp_GuardaBitacoraModificacionesEntregables
GO
CREATE PROCEDURE En_Sp_GuardaBitacoraModificacionesEntregables
@IdUsuario int,
@IdContrato int,
@IdEntregable int,
@IdArea int = null,
@IdElaborador int = null,
@IdAprobador int = null,
@Activo bit = null,
@bitAwareness bit = null
AS
BEGIN
	IF @Activo IS NOT NULL OR @IdElaborador IS NOT NULL OR @IdAprobador IS NOT NULL OR @IdArea IS NOT NULL OR @bitAwareness IS NOT NULL
	BEGIN
		INSERT INTO EN_Bitacora_EntregablesModificados(	
		IdContrato,				IdEntregable,		IdArea,
		ElaboradorAnterior,		AprobadorAnterior,	Activo,					
		ModificadoPor,			ModificadoEl,		BitAwareness) VALUES
		(@IdContrato,			@IdEntregable,		@IdArea,
		@IdElaborador,			@IdAprobador,		@Activo,
		@IdUsuario,				GETDATE(),			@bitAwareness)
	END
END
