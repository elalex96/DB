-- =============================================
-- Author:		Reyna Olvera
-- Create date: 04/03/2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ValidacionElaboracion]
    @idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE	@IdUsuarioActividad	INT	=	0, @EsUsuarioElabora	INT	=	0

	SELECT	@IdUsuarioActividad	=	
	CASE 
		ISNULL(exa.idUsuario, '')
		WHEN ''
		  THEN	A.idUsuario
		ELSE
			EXA.idUsuario
		END
	FROM	EN_InstanciasEntregable	IE
	JOIN	EN_Actividad	A
		ON	IE.ActividadID	=	A.ActividadID
	LEFT	JOIN 
		EN_ExcepcionesActividad	EXA
		ON	A.ActividadID	=	EXA.ActividadIDExcepcion
		AND EXA.IdInstanciasEntregables	=	@idInstanciaEntregable
	WHERE	IE.idInstanciaEntregable	=	@idInstanciaEntregable;


	IF(@IdUsuario	=	@IdUsuarioActividad)
	BEGIN
		SET	@EsUsuarioElabora	=	1;
	END
	ELSE
	BEGIN
		IF((SELECT	COUNT(1) FROM	EN_GruposUsuarios WHERE	IdGrupo	=	@IdUsuarioActividad AND	IdUsuario	=	@idUsuario AND IdContrato	=	@idContrato) > 0)
			BEGIN
				SET	@EsUsuarioElabora	=	1;
			END
			ELSE
			BEGIN
				SET	@EsUsuarioElabora	=	0;
			END
	END

	SELECT @EsUsuarioElabora AS EsUsuarioElabora,	A.EstadoID,	NombreEstado
	FROM	EN_InstanciasEntregable	IE

	JOIN	EN_Actividad	A
		ON	IE.ActividadID	=	A.ActividadID

	JOIN EN_Estado	E
		ON	A.EstadoID	=	E.EstadoID

	WHERE	IE.idInstanciaEntregable	=	@idInstanciaEntregable;

END


