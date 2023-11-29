IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MPY_PR_MM_ActualizarAprobacionCNDetalle'
)
    DROP PROCEDURE SP_MPY_PR_MM_ActualizarAprobacionCNDetalle;
GO
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
-- Author:		Alexander Gomez
-- Create date: 10/05/2023
-- Description:	se agrega el filtrado por usuario activo, nolocks y reacomodo de joins
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

        UPDATE dbo.MPY_MM_AceptacionCartaPCN
          SET 
              IdEstatus = @IdEstatus, 
              FechaEvaluacion = GETDATE(), 
              IdUsuarioEvaluador = @IdEvaluadorCN, 
              ComentarioEvaluador = @Comentario
        WHERE IdAceptacionCartaPCN = @IdAceptacionCartaPCN;

        SET @IdUsuarioCarga =
        (
            SELECT [CreadoPor]
            FROM [MPY_MM_AceptacionCartaPCN] (NOLOCK)
            WHERE [IdAceptacionCartaPCN] = @IdAceptacionCartaPCN
        );
        SET @Idaceptacionservi =
        (
            SELECT [IdAceptacionPedido]
            FROM [MPY_MM_AceptacionCartaPCN] (NOLOCK)
            WHERE [IdAceptacionCartaPCN] = @IdAceptacionCartaPCN
        );
        SET @statusnombre =
        (
            SELECT [TipoValidacion]
            FROM [dbo].[S_TipoValidacionDoc] (NOLOCK)
            WHERE IdTipoValidacionDoc = @IdEstatus
        );
        SET @statusNombreEn =
        (
            SELECT TipoValidacionEn
            FROM [dbo].[S_TipoValidacionDoc] (NOLOCK)
            WHERE IdTipoValidacionDoc = @IdEstatus
        );
        DECLARE @IDPRESES INT=
        (
            SELECT TOP 1 PSES.IdPRESES
            FROM Adinco.dbo.CO_SAPPRESES AS PSES (NOLOCK)
                 LEFT JOIN Adinco.dbo.CO_SAPSES AS SES (NOLOCK) 
					ON PSES.SAPPONumber = SES.PO_SAPNumer
                     AND PSES.SAPSESNumber = SES.SESReferenceNumber
                 JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK) 
					ON SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
						AND SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
						AND AP.IdAceptacionPedido = @Idaceptacionservi
        );
        DECLARE @IDSES INT=
        (
            SELECT TOP 1 SES.SESNumber
            FROM Adinco.dbo.CO_SAPPRESES AS PSES (NOLOCK)
                 LEFT JOIN Adinco.dbo.CO_SAPSES AS SES (NOLOCK) 
					ON PSES.SAPPONumber = SES.PO_SAPNumer
						AND PSES.SAPSESNumber = SES.SESReferenceNumber
                 JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK) 
					ON SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
                    AND SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
					AND AP.IdAceptacionPedido = @Idaceptacionservi
        );
        DECLARE @REFERENCE NVARCHAR(100)=
        (
            SELECT TOP 1 SES.SESReferenceNumber
            FROM Adinco.dbo.CO_SAPPRESES AS PSES (NOLOCK)
                 LEFT JOIN Adinco.dbo.CO_SAPSES AS SES (NOLOCK) 
					ON PSES.SAPPONumber = SES.PO_SAPNumer
                     AND PSES.SAPSESNumber = SES.SESReferenceNumber
                 JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK) 
					ON SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
                    AND SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
					AND AP.IdAceptacionPedido = @Idaceptacionservi
        );
        DECLARE @PO NVARCHAR(100)=
        (
            SELECT TOP 1 SES.PO_SAPNumer
            FROM Adinco.dbo.CO_SAPPRESES AS PSES (NOLOCK)
                 LEFT JOIN Adinco.dbo.CO_SAPSES AS SES (NOLOCK)
					ON PSES.SAPPONumber = SES.PO_SAPNumer
                    AND PSES.SAPSESNumber = SES.SESReferenceNumber
                 JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK) 
					ON SES.PO_SAPNumer COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
                    AND SES.SESReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
					AND AP.IdAceptacionPedido = @Idaceptacionservi
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
    FROM S_Usuario usuario (NOLOCK)
         INNER JOIN dbo.S_UsuarioProveedor uProv (NOLOCK) 
			ON usuario.IdUsuario = uProv.IdUsuario
			AND usuario.IdUsuario = @IdUsuarioCarga 
			AND usuario.Activo = 1
);
    END;