USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultarEstatusExclucionCN]    Script Date: 11/08/2021 02:07:10 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/12/2019>
-- Description:	<Cosultar estatus solicitud exclucion de carta cn>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarEstatusExclucionCN] --2172,2205
-- Add the parameters for the stored procedure here
@IdAceptacionPedido INT, 
@IdUsuario          INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

        -- Insert statements for procedure here
		DECLARE @EXISTESOLICITUD INT = (SELECT TOP 1 Id FROM RelacionCartaCNPedidoModificado WHERE IdAceptacionPedido = @IdAceptacionPedido)
        DECLARE @EXCLUCIONCARTAF BIT=
        (
            SELECT ISNULL(PedirCarta, 0)
            FROM dbo.RelacionCartaCNPedido
            WHERE IdAceptacionPedido = @IdAceptacionPedido
        );
        DECLARE @EXCLUCIONCARTA INT=
        (
            SELECT ISNULL(PedirCarta, 0)
            FROM dbo.RelacionCartaCNPedido
            WHERE IdAceptacionPedido = @IdAceptacionPedido
        );
        DECLARE @REQUISITOR NVARCHAR(500)=
        (
            SELECT TOP 1 US.Nombre
            FROM dbo.MM_Solicitud_ExclucionCN AS ECN
                 LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = ECN.IdUsuarioRequesitor
            WHERE ECN.IdAceptacionPedido = @IdAceptacionPedido
        );
        DECLARE @IDREQUISITOR INT=
        (
            SELECT TOP 1 US.IdUsuario
            FROM dbo.MM_Solicitud_ExclucionCN AS ECN
                 LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = ECN.IdUsuarioRequesitor
            WHERE ECN.IdAceptacionPedido = @IdAceptacionPedido
        );
        DECLARE @APROBADOR NVARCHAR(100)=
        (
            SELECT TOP 1 US.Nombre
            FROM dbo.MM_Solicitud_ExclucionCN AS ECN
                 LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = ECN.UsuarioAprobador
            WHERE ECN.IdAceptacionPedido = @IdAceptacionPedido
        );
        DECLARE @FECHAEVALUACION DATETIME=
        (
            SELECT TOP 1 ECN.FechaEvaluacion
            FROM dbo.MM_Solicitud_ExclucionCN AS ECN
            WHERE ECN.IdAceptacionPedido = @IdAceptacionPedido
        );
        DECLARE @FECHASOLICITUD DATETIME=
        (
            SELECT TOP 1 ECN.FechaSolicitud
            FROM dbo.MM_Solicitud_ExclucionCN AS ECN
            WHERE ECN.IdAceptacionPedido = @IdAceptacionPedido
        );
        DECLARE @IDROLUSUARIO INT=
        (
            SELECT TOP 1 UR.IdRol
            FROM dbo.S_UsuarioRol AS UR
            WHERE UR.IdUsuario = @IdUsuario
                  AND UR.IdRol = 3
                  AND UR.Activo = 1
        );
        DECLARE @IDESTATUSSOLEXC INT=
        (
            SELECT ISNULL(IdEstatus, 0)
            FROM dbo.MM_Solicitud_ExclucionCN
            WHERE IdAceptacionPedido = @IdAceptacionPedido
        );
        IF ISNULL(@IDREQUISITOR, 0) = 0
            BEGIN
                SET @IDREQUISITOR =
                (
                    SELECT TOP 1 SP.IdUsuarioSolicitante
                    FROM dbo.MM_AceptacionPedido AS AP
                         LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
                         LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
                    WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                );
        END;
        IF @IDREQUISITOR = @IdUsuario
        BEGIN
                SET @IDROLUSUARIO = 2;
        END;
        IF(ISNULL(@EXCLUCIONCARTA, 0) = 0)
            BEGIN
                SET @EXCLUCIONCARTA = 2;
        END;
            ELSE
            BEGIN
                SET @EXCLUCIONCARTA =
                (
                    SELECT ISNULL(IdEstatus, 0)
                    FROM dbo.MM_Solicitud_ExclucionCN
                    WHERE IdAceptacionPedido = @IdAceptacionPedido
                );
        END;



        SELECT ISNULL(@EXCLUCIONCARTA, 0) AS ESTATUS, --0
               ISNULL(@REQUISITOR, '') AS REQUISITOR, --1
               ISNULL(@IDROLUSUARIO, 0) AS IDUSUARIOROL, --2
               ISNULL(@APROBADOR, '') AS APROBADOR, --3
               ISNULL(@FECHAEVALUACION, GETDATE()) AS FECHAEVALAUCION, --4
               ISNULL(@FECHASOLICITUD, GETDATE()) AS FECHASOLICITUD, 
               ISNULL(@EXCLUCIONCARTAF, 0),
			   ISNULL(@EXISTESOLICITUD, 0);--5

    END;