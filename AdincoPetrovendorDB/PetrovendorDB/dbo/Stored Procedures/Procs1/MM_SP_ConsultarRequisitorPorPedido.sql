USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_SP_ConsultarRequisitorPorPedido'
)
    DROP PROCEDURE MM_SP_ConsultarRequisitorPorPedido;
/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultarRequisitorPorPedido]    Script Date: 30/08/2023 06:13:09 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	Daniel AC
-- Create date: <30-08-2023>
-- Description:	<Se consulta los datos del requisitor por medio de un IdPedido solo activos>
-- =============================================

CREATE PROCEDURE [dbo].[MM_SP_ConsultarRequisitorPorPedido]	
	@IdPedido INT,
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
AS
BEGIN
	SELECT u.Nombre,
           u.Correo,
           sp.IdProveedor,
           u.IdUsuario,
		   sp.IdSolicitudPedido
	FROM dbo.MM_Pedido p (NOLOCK)
	INNER JOIN dbo.MM_SolicitudPedido sp  (NOLOCK)
		ON p.IdSolicitudPedido = sp.IdSolicitudPedido
	INNER JOIN dbo.S_Usuario u  (NOLOCK)
		ON sp.IdUsuarioSolicitante = u.IdUsuario 
		AND u.Activo = 1 --> SOLICITANTE DEBE ESTAR ACTIVO
	WHERE p.IdPedido =  @IdPedido
END