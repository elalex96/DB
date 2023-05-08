-- =============================================
-- Author:		Reyna Olvera
-- Create date: 04/03/2020
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ValidacionAprobaciones]--10061,3,285713
    @idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE	@IdUsuarioActividad	INT	=	0, @EsUsuarioAprobador	INT	=	0, @IsAdmin INT, @NombreUsuarioAprobador VARCHAR(MAX)='';

    SELECT @IsAdmin =	COUNT(1)
    FROM dbo.AP_PerfilUsuario PU
    JOIN dbo.AP_Perfil P ON PU.PerfilID = P.IdPerfil
    JOIN dbo.AP_Rol R ON P.IdRol = R.IdRol
    WHERE UsuarioID = @idUsuario
          AND P.IdContrato =	@idContrato
          AND (R.Rol LIKE '%Administra%Entregables%' OR R.Rol LIKE '%Admin%Shell%' OR R.Rol LIKE '%Especial%BARBARA%' OR R.Rol LIKE '%CARGA%HISTO%ENI%' OR R.Rol LIKE '%SASISOPA SHELL%' OR R.Rol LIKE '%SASISOPA CRISTINA SHELL%');

	SELECT	@IdUsuarioActividad	=	
	
	 CASE	ISNULL(EXA.idUsuario, '')
				   WHEN	''	
				   THEN A.idUsuario
				   ELSE EXA.idUsuario
			   END
--	idUsuario
	FROM	EN_InstanciasEntregable	IE
	JOIN	
		EN_Actividad	A
		ON	IE.ActividadID	=	A.ActividadID

	LEFT	JOIN	
		dbo.EN_ExcepcionesActividad	EXA
		ON	A.ActividadID	=	EXA.ActividadIDExcepcion
		AND	IE.idInstanciaEntregable	=	EXA.IdInstanciasEntregables

	WHERE	IE.idInstanciaEntregable	=	@idInstanciaEntregable;


	IF(@IdUsuario	=	@IdUsuarioActividad)
	BEGIN
		SET	@EsUsuarioAprobador	=	1;
	END
	ELSE
	BEGIN
		IF((SELECT	COUNT(1)	FROM	EN_GruposUsuarios WHERE	IdGrupo	=	@IdUsuarioActividad	AND	IdUsuario	=	@idUsuario	AND	IdContrato	=	@idContrato)	>	0)
			BEGIN
				SET	@EsUsuarioAprobador	=	1;
			END
			ELSE
			BEGIN
				SET	@EsUsuarioAprobador	=	0;
			END
	END

	IF((SELECT COUNT(1)	FROM	AP_Usuario	WHERE UsuarioID	=	@IdUsuarioActividad	AND IsGrupo	=	1) >=1)
	BEGIN
		SELECT DISTINCT
		@NombreUsuarioAprobador	=
		UG.Nombre + ' (Puede realizar la accion cualquiera de los siguientes usuarios: ' +
		STUFF((
			SELECT ', '  + U.Nombre
			FROM AP_Usuario U
			INNER JOIN EN_GruposUsuarios GUT  ON U.UsuarioID	=	GUT.IdUsuario 
			WHERE GUT.IdGrupo	=	GU.IdGrupo
			FOR XML PATH('')),
			1, 2, '')+')'

			FROM	EN_GruposUsuarios GU
			JOIN AP_Usuario AS UG
				ON	GU.IdGrupo	=	UG.UsuarioID
			WHERE	GU.Activo	=	1
			  AND	UG.IsActivo	=	1
			  AND	GU.IdContrato	=	@IdContrato
			  AND	GU.IdGrupo	=	@IdUsuarioActividad
	END
	ELSE
	BEGIN
	
		SELECT	@NombreUsuarioAprobador	=	Nombre
		FROM	AP_Usuario	
		WHERE	UsuarioID	=	@IdUsuarioActividad;

	END

	SELECT @IsAdmin, @EsUsuarioAprobador AS EsUsuarioAprobador,	A.EstadoID,	
		NombreEstado, FechasLimiteElaboracion, FechasLimiteRevision, FechasLimiteAprobacion, @NombreUsuarioAprobador as NombreAprobador
	FROM	EN_InstanciasEntregable	IE

	JOIN	EN_Actividad	A
		ON	IE.ActividadID	=	A.ActividadID

	JOIN EN_Estado	E
		ON	A.EstadoID	=	E.EstadoID

	WHERE	IE.idInstanciaEntregable	=	@idInstanciaEntregable;

END
