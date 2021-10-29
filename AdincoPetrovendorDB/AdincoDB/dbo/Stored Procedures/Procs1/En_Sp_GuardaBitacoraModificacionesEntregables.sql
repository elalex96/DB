DROP PROCEDURE IF EXISTS En_Sp_GuardaBitacoraModificacionesEntregables
GO
-- =============================================
-- Author:		Luis David De La Cruz
-- Create date: 28/10/2021
-- Description:	Inserta en la tabla bitacora
-- =============================================
CREATE PROCEDURE En_Sp_GuardaBitacoraModificacionesEntregables
@IdUsuario int,
@IdContrato int,
@IdEntregable int,
@IdArea int = null,
@IdElaborador int = null,
@IdAprobador int = null,
@Activo bit = null
AS
BEGIN
	IF @Activo IS NOT NULL OR @IdElaborador IS NOT NULL OR @IdAprobador IS NOT NULL OR @IdArea IS NOT NULL 
	BEGIN
		INSERT INTO EN_Bitacora_EntregablesModificados(	
		IdContrato,				IdEntregable,		IdArea,
		ElaboradorAnterior,		AprobadorAnterior,	Activo,					
		ModificadoPor,			ModificadoEl) VALUES
		(@IdContrato,			@IdEntregable,		@IdArea,
		@IdElaborador,			@IdAprobador,		@Activo,
		@IdUsuario,				GETDATE())
	END
END