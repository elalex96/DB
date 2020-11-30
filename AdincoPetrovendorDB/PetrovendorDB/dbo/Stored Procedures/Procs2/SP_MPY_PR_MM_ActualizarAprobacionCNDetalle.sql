-- =============================================
-- Author:		DANIEL Cruz
-- Create date: 05-07-17
-- Description:	
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 12/03/2018
-- Description:	se agrega el retorno del usuario y del proveedor
-- =============================================
-- Author:		Jose Roman
-- Create date: 19-09-2018
-- Description:	Se modifica la aprobacion de CN
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_PR_MM_ActualizarAprobacionCNDetalle]
-- Add the parameters for the stored procedure here
@IdProveedor          INT, 
@IdAceptacionCartaPCN INT, 
@IdAceptacionPedido   INT, 
@IdEvaluadorCN        INT, 
@IdEstatus            INT, 
@Comentario           NVARCHAR(MAX)
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        DECLARE @IdUsuarioCarga INT;
        DECLARE @Idaceptacionservi INT;
        DECLARE @statusnombre NVARCHAR(MAX);
        DECLARE @statusNombreEn NVARCHAR(MAX);
        -- Insert statements for procedure here
        --IF @IdEstatus = 3
        --BEGIN
        --	--UPDATE dbo.MPY_CN_Aprobadores
        --	--SET EstatusAprobacion = 3,
        --	--	Comentario = @Comentario,
        --	--	FechaEvaluacion = GETDATE()
        --	--WHERE IdAceptacionPedido = @IdAceptacionPedido AND IdAprobador_CN = @IdEvaluadorCN
        --	UPDATE [dbo].[MPY_MM_AceptacionCartaPCN]
        --	SET [ComentarioEvaluador] = @Comentario,
        --	[FechaEvaluacion] =getdate(),
        --	IdEstatus = 3
        --	WHERE [IdAceptacionCartaPCN] = @IdAceptacionCartaPCN
        --END
        --ELSE
        --BEGIN
        --UPDATE dbo.MPY_CN_Aprobadores
        --SET EstatusAprobacion = @IdEstatus,
        --   Comentario = @Comentario,
        --FechaEvaluacion = GETDATE()
        --WHERE IdAprobador_CN = @IdEvaluadorCN
        ----TODOS LOS EVALUADORES QUE HAN APROBADO LA CARTA
        --DECLARE @NAPROBADORESEV INT = (SELECT COUNT(ACN.IdAprobador_CN) 
        --							FROM dbo.MPY_CN_Aprobadores AS ACN
        --							WHERE ACN.IdAceptacionPedido = @IdAceptacionPedido AND ACN.EstatusAprobacion = 2)
        ----TODOS LOS EVALUADORES
        --DECLARE @NAPROBADORES INT = (SELECT COUNT(ACN.IdAprobador_CN) 
        --								FROM dbo.MPY_CN_Aprobadores AS ACN
        --								WHERE ACN.IdAceptacionPedido = @IdAceptacionPedido)
        --SI TODOS LOS EVALUADORES QUE HAN APROBADO ES IGUAL A LA CANTIDAD DE APROBADORES, TERMINO LA APROBACION DE LA CARTA Y SE APRUEBA
        --IF @NAPROBADORES = @NAPROBADORESEV
        --BEGIN
        UPDATE dbo.MPY_MM_AceptacionCartaPCN
          SET 
              IdEstatus = @IdEstatus, 
              FechaEvaluacion = GETDATE(), 
              IdUsuarioEvaluador = @IdEvaluadorCN, 
              ComentarioEvaluador = @Comentario
        WHERE IdAceptacionCartaPCN = @IdAceptacionCartaPCN;
        --	END
        --END

        SET @IdUsuarioCarga =
        (
            SELECT [CreadoPor]
            FROM [MPY_MM_AceptacionCartaPCN]
            WHERE [IdAceptacionCartaPCN] = @IdAceptacionCartaPCN
        );
        SET @Idaceptacionservi =
        (
            SELECT [IdAceptacionPedido]
            FROM [MPY_MM_AceptacionCartaPCN]
            WHERE [IdAceptacionCartaPCN] = @IdAceptacionCartaPCN
        );
        SET @statusnombre =
        (
            SELECT [TipoValidacion]
            FROM [dbo].[S_TipoValidacionDoc]
            WHERE IdTipoValidacionDoc = @IdEstatus
        );
        SET @statusNombreEn =
        (
            SELECT TipoValidacionEn
            FROM [dbo].[S_TipoValidacionDoc]
            WHERE IdTipoValidacionDoc = @IdEstatus
        );
        DECLARE @IDPRESES INT=
        (
            SELECT TOP 1 PSES.IdPRESES
            FROM Adinco.dbo.CO_SAPPRESES AS PSES
                 LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber
                                                          AND SES.SESReferenceNumber = PSES.SAPSESNumber
                 LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS
                                                                AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
            WHERE AP.IdAceptacionPedido = @Idaceptacionservi
        );
        DECLARE @IDSES INT=
        (
            SELECT TOP 1 SES.SESNumber
            FROM Adinco.dbo.CO_SAPPRESES AS PSES
                 LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber
                                                          AND SES.SESReferenceNumber = PSES.SAPSESNumber
                 LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS
                                                                AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
            WHERE AP.IdAceptacionPedido = @Idaceptacionservi
        );
        DECLARE @REFERENCE NVARCHAR(100)=
        (
            SELECT TOP 1 SES.SESReferenceNumber
            FROM Adinco.dbo.CO_SAPPRESES AS PSES
                 LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber
                                                          AND SES.SESReferenceNumber = PSES.SAPSESNumber
                 LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS
                                                                AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
            WHERE AP.IdAceptacionPedido = @Idaceptacionservi
        );
        DECLARE @PO NVARCHAR(100)=
        (
            SELECT TOP 1 SES.PO_SAPNumer
            FROM Adinco.dbo.CO_SAPPRESES AS PSES
                 LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber
                                                          AND SES.SESReferenceNumber = PSES.SAPSESNumber
                 LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS
                                                                AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
            WHERE AP.IdAceptacionPedido = @Idaceptacionservi
        );
(
    SELECT usuario.nombre, 
           @Idaceptacionservi, 
           @statusnombre, 
           Correo, 
           uProv.IdUsuario, 
           uProv.IdProveedor, 
           @PO, 
           @IDSES, 
           @REFERENCE, 
           @IDPRESES, 
           @statusNombreEn
    FROM S_Usuario usuario
         INNER JOIN dbo.S_UsuarioProveedor uProv ON uProv.IdUsuario = usuario.IdUsuario
    WHERE usuario.IdUsuario = @IdUsuarioCarga
);
    END;