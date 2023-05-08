-- =============================================
-- Author:		Manuel Cruz
-- Create date: 09-09-2021
-- Description:	Listado de entregables rechazados para tener seguimiento
-- =============================================
CREATE PROCEDURE [dbo].[EN_EntregablesRechazados]
-- EXEC EN_EntregablesRechazados 10150,10055,'2020-01-01','2021-09-30'
	-- Add the parameters for the stored procedure here
    @IdUsuario INT,
    @IdContrato INT,
	@FechaInicial DATE,
	@FechaFinal DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	/*Determinar si es administrador*/
	DECLARE @IsAdmin INT = 0
	SELECT @IsAdmin = COUNT(P.IdPerfil)--SELECT DISTINCT P.Descripcion, U.UsuarioID, U.Nombre
	FROM AP_Usuario U
	JOIN AP_PerfilUsuario PU ON U.UsuarioID = PU.UsuarioID
	JOIN AP_Perfil P ON PU.PerfilID = P.IdPerfil
	WHERE (P.Descripcion LIKE ('%Admin%')
	OR P.Descripcion LIKE ('%Admon%'))
	AND U.UsuarioID = @IdUsuario
	AND P.IdContrato = @IdContrato

	IF(@IsAdmin > 0)
	BEGIN
	/*Consulta del reporte*/
		SELECT
			IE.idInstanciaEntregable AS ID,
			CAST(IE.FechaCalculadaEntregaReg AS DATE) AS FechaCalculadaEntregaReg,
			E.DocumentoEntregable,
			A.NombreArea AS 'Area/Funcion',
			ES.NombreEstado AS Estatus,
			STUFF((SELECT DISTINCT ' | ' + HAA.Comentario
			FROM EN_HistorialAprobacionesLineaTiempo HAA WHERE HAA.idInstanciaEntregable = HA.idInstanciaEntregable AND HAA.Rechazado = 1 FOR XML PATH('')
						), 1, 1, '') AS Comentario,
			STUFF((SELECT DISTINCT ' | ' + LTRIM(CAST(HAA.CreadoEn AS DATE))
			FROM EN_HistorialAprobacionesLineaTiempo HAA WHERE HAA.idInstanciaEntregable = HA.idInstanciaEntregable AND HAA.Rechazado = 1 FOR XML PATH('')
						), 1, 1, '') AS Fecha,
			U.NOMBRE AS 'Responsable de Entregables',
			COUNT(IdHistorialAprobacionesVersion) AS 'Cant Veces Rechazada',
			UR.Nombre AS 'Usuario que Rechazo'--SELECT *
		FROM EN_ContratoEntregable CE
		JOIN EN_Area A ON CE.IdArea = A.idArea AND CE.IDCONTRATO = A.idContrato
		JOIN EN_Entregable E ON CE.IdEntregable	= E.IdEntregable AND E.BitJOA = 0
		JOIN EN_InstanciasEntregable IE ON CE.IdContratoEntregable = IE.IdContratoEntregable AND IE.Activo = 1
		JOIN EN_Actividad AA ON IE.ActividadID = AA.ActividadID
		JOIN EN_HistorialAprobacionesLineaTiempo HA ON IE.idInstanciaEntregable = HA.idInstanciaEntregable AND HA.Rechazado	= 1
		JOIN EN_Estado ES ON AA.EstadoID = ES.EstadoID
		JOIN EN_ACTIVIDAD AR ON CE.IDCONTRATOENTREGABLE = AR.IDCONTRATOENTREGABLE AND AR.ESTADOID = 10000
		JOIN AP_USUARIO U ON AR.IDUSUARIO = U.USUARIOID
		--JOIN #Areas TAR ON A.NombreArea = TAR.Area
		JOIN AP_Usuario UR ON HA.CreadoPor = UR.UsuarioID
		WHERE CE.IdContrato = @IdContrato
		--AND U.UsuarioID = @IdUsuario
		AND (CAST(HA.CreadoEn AS DATE) >= @FechaInicial AND CAST(HA.CreadoEn AS DATE) <= @FechaFinal)
		GROUP BY
			IE.idInstanciaEntregable,
			CAST(IE.FechaCalculadaEntregaReg AS DATE),
			E.DocumentoEntregable,
			A.NombreArea,
			ES.NombreEstado,
			U.NOMBRE,
			IE.idInstanciaEntregable,
			HA.idInstanciaEntregable,
			HA.Rechazado,
			UR.Nombre
		ORDER BY
			ES.NOMBREESTADO,
			IE.IDINSTANCIAENTREGABLE
	END
	ELSE
	BEGIN
	/*Determinar las áreas a las que pertenece el usuario*/
		CREATE TABLE #Areas
		(
			ID INT IDENTITY(1, 1),
			Area NVARCHAR(150)
		);
		INSERT INTO #Areas (Area)
		SELECT REPLACE(P.NombrePermiso, 'Acceso a Entregables de ', '')
		FROM dbo.AP_PermisosUsuarios PU
		JOIN dbo.AP_Permiso P ON PU.IdPermiso = P.IdPermiso
		WHERE UsuarioID = @IdUsuario AND idContrato = @IdContrato AND P.BitActivo = 1 AND PU.BitActivo = 1;
	/*Consulta del reporte*/
		SELECT
			IE.idInstanciaEntregable AS ID,
			CAST(IE.FechaCalculadaEntregaReg AS DATE) AS FechaCalculadaEntregaReg,
			E.DocumentoEntregable,
			A.NombreArea AS 'Area/Funcion',
			ES.NombreEstado AS Estatus,
			STUFF((SELECT DISTINCT ' | ' + HAA.Comentario
			FROM EN_HistorialAprobacionesLineaTiempo HAA WHERE HAA.idInstanciaEntregable = HA.idInstanciaEntregable AND HAA.Rechazado = 1 FOR XML PATH('')
						), 1, 1, '') AS Comentario,
			STUFF((SELECT DISTINCT ' | ' + LTRIM(CAST(HAA.CreadoEn AS DATE))
			FROM EN_HistorialAprobacionesLineaTiempo HAA WHERE HAA.idInstanciaEntregable = HA.idInstanciaEntregable AND HAA.Rechazado = 1 FOR XML PATH('')
						), 1, 1, '') AS Fecha,
			U.NOMBRE AS 'Responsable de Entregables',
			COUNT(IdHistorialAprobacionesVersion) AS 'Cant Veces Rechazada',
			UR.Nombre AS 'Usuario que Rechazo'--SELECT *
		FROM EN_ContratoEntregable CE
		JOIN EN_Area A ON CE.IdArea = A.idArea AND CE.IDCONTRATO = A.idContrato
		JOIN EN_Entregable E ON CE.IdEntregable	= E.IdEntregable AND E.BitJOA = 0
		JOIN EN_InstanciasEntregable IE ON CE.IdContratoEntregable = IE.IdContratoEntregable AND IE.Activo = 1
		JOIN EN_Actividad AA ON IE.ActividadID = AA.ActividadID
		JOIN EN_HistorialAprobacionesLineaTiempo HA ON IE.idInstanciaEntregable = HA.idInstanciaEntregable AND HA.Rechazado	= 1
		JOIN EN_Estado ES ON AA.EstadoID = ES.EstadoID
		JOIN EN_ACTIVIDAD AR ON CE.IDCONTRATOENTREGABLE = AR.IDCONTRATOENTREGABLE AND AR.ESTADOID = 10000
		JOIN AP_USUARIO U ON AR.IDUSUARIO = U.USUARIOID
		JOIN #Areas TAR ON A.NombreArea = TAR.Area
		JOIN AP_Usuario UR ON HA.CreadoPor = UR.UsuarioID
		WHERE CE.IdContrato = @IdContrato
		--AND U.UsuarioID = @IdUsuario
		AND (CAST(HA.CreadoEn AS DATE) >= @FechaInicial AND CAST(HA.CreadoEn AS DATE) <= @FechaFinal)
		GROUP BY
			IE.idInstanciaEntregable,
			CAST(IE.FechaCalculadaEntregaReg AS DATE),
			E.DocumentoEntregable,
			A.NombreArea,
			ES.NombreEstado,
			U.NOMBRE,
			IE.idInstanciaEntregable,
			HA.idInstanciaEntregable,
			HA.Rechazado,
			UR.Nombre
		ORDER BY
			ES.NOMBREESTADO,
			IE.IDINSTANCIAENTREGABLE
	END

END