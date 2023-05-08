-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/04/2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[EN_ChecaEstatusPorInstanciaEntregable]
    @idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT
AS
BEGIN
    SET NOCOUNT ON;
	Declare @IsAdmin int;

    SELECT @IsAdmin = COUNT(1)
    FROM dbo.AP_PerfilUsuario PU
    JOIN dbo.AP_Perfil P ON PU.PerfilID = P.IdPerfil
    JOIN dbo.AP_Rol R ON P.IdRol = R.IdRol
    WHERE UsuarioID = @idUsuario
          AND P.IdContrato =@idContrato
          AND R.Rol LIKE '%Administrador%Entregables%';


    SELECT      E.EstadoID,
	CASE ISNULL(EXAE.idUsuario, '')
                                WHEN ''
                                    THEN
                                    AE.idUsuario
                                ELSE
                                    EXAE.idUsuario
                 END    AS idUsuario,
                E.NombreEstado,
					CASE ISNULL(EXAR.idUsuario, 0)
                                WHEN 0
                                    THEN
                                     ISNULL(AR.idUsuario, 0)
                                ELSE
                                   EXAR.idUsuario
                 END    AS idUsuario,
					CASE ISNULL(EXAP.idUsuario, 0)
                                WHEN 0
                                    THEN
                                     ISNULL( AP.idUsuario, 0)
                                ELSE
                                   EXAP.idUsuario
                 END    AS idUsuario,
                I.FechasLimiteRevision,
                I.FechasLimiteAprobacion,
                I.FechasLimiteElaboracion,
				CASE ISNULL(EXAE.idUsuario, '')
                                WHEN ''
                                    THEN
                                    UE.Nombre
                                ELSE
                                    UXE.Nombre
                 END    AS Nombre,
			 	CASE ISNULL(EXAR.idUsuario, 0)
                                WHEN 0
                                    THEN
                                     ISNULL(UR.Nombre, '')
                                ELSE
                                   UXR.Nombre
                 END    AS Nombre,
             
					CASE ISNULL(EXAP.idUsuario, 0)
                                WHEN 0
                                    THEN
                                   ua.Nombre
                                ELSE
                                   UXP.Nombre
                 END    AS Nombre,
				 @IsAdmin as isAdmin

      FROM      EN_InstanciasEntregable	I
     JOIN	EN_Actividad AE
        ON	I.IdContratoEntregable	=	AE.IdContratoEntregable 
       AND	AE.EstadoID             =	10000

     JOIN	EN_Actividad	AR
        ON	I.IdContratoEntregable	=	AR.IdContratoEntregable
       AND	AR.EstadoID	=	10001

     JOIN	EN_Actividad	AP
        ON	I.IdContratoEntregable	=	AP.IdContratoEntregable
       AND	AP.EstadoID	=	10002

     JOIN	dbo.AP_Usuario	UE
        ON	AE.idUsuario	=	UE.UsuarioID 

     JOIN	dbo.AP_Usuario	UA
        ON	AP.idUsuario	=	UA.UsuarioID  
		     
     JOIN	dbo.AP_Usuario	UR
        ON	AR.idUsuario	=	UR.UsuarioID 
		     
     JOIN	EN_Actividad	AC
        ON	I.ActividadID	=	AC.ActividadID 
		  
     JOIN	EN_Estado	E
        ON	AC.EstadoID	=	E.EstadoID 
       AND	I.IdContratoEntregable	=	AC.IdContratoEntregable

	LEFT	JOIN	dbo.EN_ExcepcionesActividad	EXAE
		ON	AE.ActividadID	=	EXAE.ActividadIDExcepcion
		AND I.idInstanciaEntregable	=	EXAE.IdInstanciasEntregables

	LEFT	JOIN	dbo.AP_Usuario	UXE
		ON	EXAE.idUsuario	=	UXE.UsuarioID

	LEFT	JOIN	dbo.EN_ExcepcionesActividad	EXAR
		ON	AR.ActividadID	=	EXAR.ActividadIDExcepcion
		AND	I.idInstanciaEntregable	=	EXAR.IdInstanciasEntregables

	LEFT	JOIN	dbo.AP_Usuario	UXR
		ON	UXR.UsuarioID	=	EXAR.idUsuario

	LEFT	JOIN	dbo.EN_ExcepcionesActividad	EXAP
		ON	EXAP.ActividadIDExcepcion	=	AP.ActividadID
			AND	I.idInstanciaEntregable	=	EXAP.IdInstanciasEntregables

	LEFT	JOIN	dbo.AP_Usuario	UXP
		ON	EXAP.idUsuario	=	UXP.UsuarioID

    WHERE	idInstanciaEntregable = @idInstanciaEntregable;

END;





