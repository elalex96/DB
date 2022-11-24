CREATE PROCEDURE [dbo].[sp_CreaAlertasInstancias]
AS
    BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Crea Alertas 
-- =============================================
-- 20190701	BAAC	Se modifica para que no inserte en S_Notificación, solo haga el push en la aplicacion
-- =============================================
SET NOCOUNT ON 

CREATE TABLE #DatosAlertaEntregables
    (
        IDAlerta                   INT IDENTITY(1, 1),
        idInstanciaEntregable      INT,
        Periodo                    DATE,
        FECHALIMITEACCION          DATE,
        ActividadIDACTUAL          INT,
        EstadoIDACTUAL             INT,
        NombreACTUAL               VARCHAR(500),
        UsuarioIDACTUAL            INT,
        ParaACTUAL                 NVARCHAR(MAX),
        NombreEstadoACTUAL         NVARCHAR(MAX),
        ActividadIDSiguiente       INT,
        IDEstadoSiguiente          INT,
        NombreSiguiente            NVARCHAR(MAX),
        UsuarioIDSiguiente         INT,
        ParaSiguiente              NVARCHAR(MAX),
        EstadoSiguiente            NVARCHAR(MAX),
        FECHALIMITEACCIONSIGUIENTE DATE,
        tipoCorreo                 NVARCHAR(MAX),
        IdEntregable               INT,
        DocumentoEntregable        NVARCHAR(MAX),
        TextoTipoAlertaActual      NVARCHAR(MAX),
        TextoTipoAlertaActual2     NVARCHAR(MAX),
        TextoTipoAlertaSiguiente   NVARCHAR(MAX),
        TextoTipoAlertaSiguiente2  NVARCHAR(MAX)
    );

DECLARE @HOY DATE,@NombreDia NVARCHAR(100);
SET @HOY = GETDATE();
SELECT @NombreDia= NombreDia FROM dbo.AP_Calendario WHERE IdFecha=@HOY;

IF(@NombreDia NOT IN ('Sábado','Domingo' ))
BEGIN
     
        --=====================================================================================================================================================================================
        INSERT INTO #DatosAlertaEntregables
            (
                idInstanciaEntregable,
                Periodo,
                FECHALIMITEACCION,
                ActividadIDACTUAL,
                EstadoIDACTUAL,
                NombreACTUAL,
                UsuarioIDACTUAL,
                ParaACTUAL,
                NombreEstadoACTUAL,
                ActividadIDSiguiente,
                IDEstadoSiguiente,
                NombreSiguiente,
                UsuarioIDSiguiente,
                ParaSiguiente,
                EstadoSiguiente,
                FECHALIMITEACCIONSIGUIENTE,
                tipoCorreo,
                IdEntregable,
                DocumentoEntregable,
                TextoTipoAlertaActual,
                TextoTipoAlertaActual2,
                TextoTipoAlertaSiguiente,
                TextoTipoAlertaSiguiente2
            )
        EXEC [sp_ExtraeDatosAlertasInstancias];
        --=====================================================================================================================
        --=======================================NOTIFICACIONES PUSH-===========================================================
        INSERT INTO dbo.AM_OneSignalNotificaciones
            (
                Para,
                Player,
                TItulo,
                Subtitulo,
                Mensaje,
                FechaCreacion,
                FechaModificacion,
                Enviado,
                Enviar,
                IdTareaOrigen
            )
                    SELECT
                            DAEA.ParaACTUAL,
                            OSP.PlayerId,
                            tipoCorreo,
                            'En. Pendiente ' + LTRIM(DAEA.IdEntregable)        AS subtitulo,
                            'Estimado, Se te informa que tienes pendiente una ' + DAEA.NombreEstadoACTUAL
                            + ' del entregable: ' + DAEA.DocumentoEntregable,
                            GETDATE(),
                            GETDATE(),
                            0,
                            1,
                            0
                    FROM
                            dbo.AM_OneSignalPlayers OSP
                        JOIN
                            #DatosAlertaEntregables DAEA
                                ON DAEA.ParaACTUAL = OSP.Usuario
                    WHERE
                            DAEA.ActividadIDACTUAL IS NOT NULL
                          --    AND DAEA.ParaACTUAL IN ('reyna.olvera@adinco.mx', 'reyna.olvera@ogss.com.mx')
							;
        --=====================================================================================================================
        INSERT INTO dbo.AM_OneSignalNotificaciones
            (
                Para,
                Player,
                TItulo,
                Subtitulo,
                Mensaje,
                FechaCreacion,
                FechaModificacion,
                Enviado,
                Enviar,
                IdTareaOrigen
            )
                    SELECT
                            DAES.ParaSiguiente,
                            OSP.PlayerId,
                            tipoCorreo,
                            'En. Pendiente ' + LTRIM(DAES.IdEntregable) AS subtitulo,
                            'Estimado, Se te informa que el usuario ' + DAES.NombreACTUAL + ' tiene pendiente una '
                            + DAES.NombreEstadoACTUAL + ' del entregable: ' + DAES.DocumentoEntregable,
                            GETDATE(),
                            GETDATE(),
                            0,
           1,
                            0
                    FROM
                            dbo.AM_OneSignalPlayers OSP
                        JOIN
                            #DatosAlertaEntregables DAES
                                ON DAES.ParaSiguiente = OSP.Usuario
                    WHERE
                            DAES.ActividadIDSiguiente IS NOT NULL;
	END

END;

