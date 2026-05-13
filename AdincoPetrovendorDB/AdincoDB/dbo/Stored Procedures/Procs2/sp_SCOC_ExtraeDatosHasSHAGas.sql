/****** Object:  StoredProcedure [dbo].[sp_SCOC_ExtraeDatosHasSHAGas]    Script Date: 09/02/2019 03:32:09 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180904
-- Description:	extrae datos del hassha
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCOC_ExtraeDatosHasSHAGas] --10040,2,'2019-01-01'
    @idContrato  INT,
    @idUsuario   INT,
    @MesResporte DATE
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT
                RazonSocial,
                MAX(CONVERT(DATETIME, en.CreadoEn))                                                    CreadoEN,
                CONVERT(INT, CONVERT(DATETIME, en.CreadoEn))                                           AS CreadoENINT,
                REPLACE(REPLACE(C.IDRegFiducidiario, 'RF-C', ''), '-', '')                             AS IDRegFiducidiario,
                (CONVERT(INT, CONVERT(DATETIME, en.CreadoEn)))
                + ((REPLACE(REPLACE(C.IDRegFiducidiario, 'RF-C', ''), '-', '')))                       AS HASSHAContratista,
                en.CreadoPor,
                C.IdContrato,
                CASE N.AprobadoRepPEP
                    WHEN 0
                        THEN NULL
                    WHEN 1
                        THEN N.IdUsuarioAprobadoRepPEP
                END                                                                                    idAprobadoScoc,
                CONVERT(INT, CONVERT(DATETIME, N.FechaAprobacionRepPEP))                               AS FechaAproboINT,
                CASE N.FechaAprobacionRepPEP
                    WHEN NULL
                        THEN ISNULL(N.FechaAprobacionRepPEP, '')
                    ELSE
                (CONVERT(DATETIME, N.FechaAprobacionRepPEP))
                END                                                                                    AS CreadoENAprobacion,
                ISNULL((CONVERT(INT, CONVERT(DATETIME, en.CreadoEn))) + N.IdUsuarioAprobadoRepPEP, '') AS HASSHAAprobador,
                ISNULL(Nombre, '')                                                                     AS NombreAprobador
        FROM
                dbo.SCOC_ReporteDiarioGas  en
            LEFT JOIN
                dbo.SCOC_EnvioNotificacion N
                    ON en.MesReporte = N.MesReporte
                       AND en.IdContrato = N.idContrato
                       AND N.AprobadoRepPEP = 1
            LEFT JOIN
                dbo.AP_Usuario
                    ON AP_Usuario.UsuarioID = N.IdUsuarioAprobadoRepPEP
            JOIN
                dbo.CO_Contrato            C
                    ON C.IdContrato = en.IdContrato
            JOIN
                dbo.CO_Contratista
                    ON CO_Contratista.IdContratista = C.IdContratista
        WHERE
                en.MesReporte = @MesResporte
                AND C.IdContrato = @idContrato
        GROUP BY
                RazonSocial,
                CONVERT(INT, CONVERT(DATETIME, en.CreadoEn)),
                REPLACE(REPLACE(C.IDRegFiducidiario, 'RF-C', ''), '-', ''),
                (CONVERT(INT, CONVERT(DATETIME, en.CreadoEn)))
                + ((REPLACE(REPLACE(C.IDRegFiducidiario, 'RF-C', ''), '-', ''))),
                en.CreadoPor,
                C.IdContrato,
                CASE N.AprobadoRepPEP
                    WHEN 0
                        THEN NULL
                    WHEN 1
                        THEN N.IdUsuarioAprobadoRepPEP
                END,
                CONVERT(INT, CONVERT(DATETIME, N.FechaAprobacionRepPEP)),
                CASE N.FechaAprobacionRepPEP
                    WHEN NULL
                        THEN ISNULL(N.FechaAprobacionRepPEP, '')
                    ELSE
                (CONVERT(DATETIME, N.FechaAprobacionRepPEP))
                END,
                ISNULL((CONVERT(INT, CONVERT(DATETIME, en.CreadoEn))) + N.IdUsuarioAprobadoRepPEP, ''),
                ISNULL(Nombre, '');

    END;

