-- =============================================
-- Author:		Reyna Olvera
-- Create date: 03/05/2018
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EN_ObtieneInformacionEntregable]--285718	,10061,3,10000
    @idInstanciaEntregable INT,
    @idUsuario INT,
    @idContrato INT,
    @TipoAprobador INT
AS
BEGIN
    SET NOCOUNT ON;
	
	CREATE	TABLE	#Revisores(FechasLimiteRevision DATETIME,
							   IddRevision INT,
							   idUsuario INT,
							   Nombre	VARCHAR(250),
							   Usuario	VARCHAR(250),
							   ActividadID INT);

    IF (@TipoAprobador = 10000) --Revisor
    BEGIN
	INSERT #Revisores (FechasLimiteRevision,
							   IddRevision,
							   idUsuario,
							   Nombre,
							   Usuario,
							   ActividadID)
		SELECT IE.FechasLimiteRevision,
            IddRevision = 3,
            CASE ISNULL(EXAR.idUsuario, '')
				WHEN ''		THEN	A1.idUsuario
				ELSE	EXAR.idUsuario end as idUsuario,
            CASE ISNULL(EXAR.idUsuario, '')
				WHEN ''	THEN	UR.Nombre
				ELSE	UXR.Nombre end as Nombre,
            CASE ISNULL(EXAR.idUsuario, '')
				WHEN ''	THEN	UR.Usuario
				ELSE	UXR.Usuario end as Usuario,
			A1.ActividadID
		FROM	EN_InstanciasEntregable	IE

		JOIN	EN_Actividad	A1
		ON	A1.IdContratoEntregable	=	IE.IdContratoEntregable
		AND	A1.EstadoID	=	10001

		JOIN	AP_Usuario	UR
		ON	UR.UsuarioID	=	A1.idUsuario

		LEFT	JOIN	dbo.EN_ExcepcionesActividad	EXAR
		ON	EXAR.ActividadIDExcepcion	=	A1.ActividadID
		AND	ie.idInstanciaEntregable	=	EXAR.IdInstanciasEntregables

		LEFT	JOIN	dbo.AP_Usuario	UXR
		ON	UXR.UsuarioID	=	EXAR.idUsuario

		WHERE	idInstanciaEntregable	=	@idInstanciaEntregable
		ORDER	BY	A1.creadoEn	asc;


				IF((SELECT	ISNULL(IsGrupo,0) FROM #Revisores	R JOIN	AP_Usuario	U ON	R.idUsuario	=	U.UsuarioID)	>=	1)
				BEGIN
					SELECT G.FechasLimiteRevision,IddRevision,U.UsuarioID,U.Nombre,U.Usuario,G.ActividadID	--EXTRAE TODOS LOS USUARIOS DEL GRUPO
					FROM	#Revisores	G

					JOIN	EN_GruposUsuarios	GU
						ON	G.idUsuario	=	GU.IdGrupo

					JOIN	AP_Usuario	U
						ON	GU.IdUsuario	=	U.UsuarioID
				END
				ELSE
				BEGIN
					SELECT	* FROM #Revisores			--NO CONTIENE GRUPOS
				END
    END;

    ELSE IF (@TipoAprobador = 10001) --Aprobador
    BEGIN

		SELECT IE.FechasLimiteAprobacion,
			IddRevision = 4,
			CASE ISNULL(EXAR.idUsuario, '')
			WHEN ''
				THEN
				A1.idUsuario
			ELSE
				EXAR.idUsuario end as idUsuario,

			CASE ISNULL(EXAR.idUsuario, '')
			WHEN ''
				THEN
				UR.Nombre
			ELSE
				UXR.Nombre end as Nombre,
					
			CASE ISNULL(EXAR.idUsuario, '')
			WHEN ''
				THEN
				UR.Usuario
			ELSE
				UXR.Usuario end as Usuario,
			A1.ActividadID
			FROM	EN_InstanciasEntregable	IE
			JOIN	EN_Actividad	A1
				ON	A1.IdContratoEntregable	=	IE.IdContratoEntregable
				AND	A1.EstadoID	=	10002

			JOIN	AP_Usuario	UR
            ON	UR.UsuarioID	=	A1.idUsuario

			LEFT JOIN	dbo.EN_ExcepcionesActividad	EXAR
				ON	EXAR.ActividadIDExcepcion	=	A1.ActividadID
				AND	ie.idInstanciaEntregable	=	EXAR.IdInstanciasEntregables

			LEFT	JOIN	dbo.AP_Usuario	UXR
				ON	UXR.UsuarioID	=	EXAR.idUsuario

         WHERE	idInstanciaEntregable	=	@idInstanciaEntregable
		 ORDER	BY	A1.creadoEn	asc;
    END;

END;