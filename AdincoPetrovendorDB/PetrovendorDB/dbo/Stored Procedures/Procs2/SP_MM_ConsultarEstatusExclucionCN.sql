-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <09/12/2019>
-- Description:	<Cosultar estatus solicitud exclucion de carta cn>
--> Daniel AC /30-11-2022 --> Se agrega top 1 y orden desc para obtener la solicitud mas reciente 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarEstatusExclucionCN] 
-- Add the parameters for the stored procedure here
@IdAceptacionPedido INT, 
@IdUsuario          INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
		DECLARE @EXISTESOLICITUD INT
		DECLARE @EXCLUCIONCARTAF BIT
		DECLARE @EXCLUCIONCARTA INT
		DECLARE @REQUISITOR NVARCHAR(500)
		DECLARE @IDREQUISITOR INT
		DECLARE @APROBADOR NVARCHAR(100)
		DECLARE @FECHAEVALUACION DATETIME
		DECLARE @FECHASOLICITUD DATETIME
		DECLARE @IDROLUSUARIO INT
		DECLARE @IDESTATUSSOLEXC INT

        -- Insert statements for procedure here
		SET @EXISTESOLICITUD = (SELECT TOP 1 Id 
										FROM RelacionCartaCNPedidoModificado 
										WHERE IdAceptacionPedido = @IdAceptacionPedido)

       

		SELECT @EXCLUCIONCARTAF = ISNULL(PedirCarta, 0),
		@EXCLUCIONCARTA = ISNULL(PedirCarta, 0)
        FROM dbo.RelacionCartaCNPedido
        WHERE IdAceptacionPedido = @IdAceptacionPedido

		SELECT TOP 1 
		@REQUISITOR = US.Nombre,
		@IDREQUISITOR = US.IdUsuario
        FROM dbo.MM_Solicitud_ExclucionCN AS ECN
                LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = ECN.IdUsuarioRequesitor
        WHERE ECN.IdAceptacionPedido = @IdAceptacionPedido
		ORDER BY ECN.IdAprobacionExclucionCN DESC 

              
		SELECT TOP 1 
		@APROBADOR = US.Nombre
        FROM dbo.MM_Solicitud_ExclucionCN AS ECN
                LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = ECN.UsuarioAprobador
        WHERE ECN.IdAceptacionPedido = @IdAceptacionPedido
		ORDER BY ECN.IdAprobacionExclucionCN DESC 

        SELECT TOP 1 
		@FECHAEVALUACION = ECN.FechaEvaluacion,
		@FECHASOLICITUD =  ECN.FechaSolicitud,
		@IDESTATUSSOLEXC=  ISNULL(ECN.IdEstatus, 0)
            FROM dbo.MM_Solicitud_ExclucionCN AS ECN
            WHERE ECN.IdAceptacionPedido = @IdAceptacionPedido
			ORDER BY ECN.IdAprobacionExclucionCN DESC 
   

        SET @IDROLUSUARIO =
        (
            SELECT TOP 1 UR.IdRol
            FROM dbo.S_UsuarioRol AS UR
            WHERE UR.IdUsuario = @IdUsuario
                  AND UR.IdRol = 3 --> CTE  APROBADOR DE CARTAS CN
                  AND UR.Activo = 1 --> CTE ESTE ACTIVO
        );
		       

        IF ISNULL(@IDREQUISITOR, 0) = 0
            BEGIN
                SET @IDREQUISITOR =
                (
                    SELECT TOP 1 SP.IdUsuarioSolicitante
                    FROM dbo.MM_AceptacionPedido AS AP
                         LEFT JOIN dbo.MM_Pedido AS P 
							ON AP.IdPedido = P.IdPedido 
                         LEFT JOIN dbo.MM_SolicitudPedido AS SP 
							ON P.IdSolicitudPedido = SP.IdSolicitudPedido 
                    WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
                );
        END;

        IF @IDREQUISITOR = @IdUsuario
        BEGIN
                SET @IDROLUSUARIO = 2; --> ES REQUISITOR
        END;
        IF(ISNULL(@EXCLUCIONCARTA, 0) = 0)
            BEGIN
                SET @EXCLUCIONCARTA = 2; --> SE HA SOLICITADO EXCLUSIÓN DE CARTA
        END;
            ELSE
            BEGIN
			    --> NO HAY EXCLUSIÓN DE CARTA PERO BUSCAR SI HUBO ALGUNA SOLICITUD PARA MOSTRAR ESTATUS 
                SET @EXCLUCIONCARTA =
                (
                    SELECT TOP 1 ISNULL(IdEstatus, 0)
                    FROM dbo.MM_Solicitud_ExclucionCN
                    WHERE IdAceptacionPedido = @IdAceptacionPedido
					ORDER BY IdAprobacionExclucionCN DESC 
                );
        END;



        SELECT ISNULL(@EXCLUCIONCARTA, 0) AS ESTATUS, --0
               ISNULL(@REQUISITOR, '') AS REQUISITOR, --1
               ISNULL(@IDROLUSUARIO, 0) AS IDUSUARIOROL, --2
               ISNULL(@APROBADOR, '') AS APROBADOR, --3
               ISNULL(@FECHAEVALUACION, GETDATE()) AS FECHAEVALAUCION, --4
               ISNULL(@FECHASOLICITUD, GETDATE()) AS FECHASOLICITUD, -- 5
               ISNULL(@EXCLUCIONCARTAF, 0) AS EXCLUCIONCARTAF,--6
			   ISNULL(@EXISTESOLICITUD, 0) AS EXISTESOLICITUD;--7

    END;