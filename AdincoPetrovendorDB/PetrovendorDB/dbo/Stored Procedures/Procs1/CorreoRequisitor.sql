USE [Petrovendor]
GO
  IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'CorreoRequisitor'
)
DROP PROCEDURE CorreoRequisitor;   
GO 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel Ac
-- Create date: 21/03/2024
-- Description:	Consultar detalle de requisición y el requisitor y su estatus de usuario activo
-- =============================================
CREATE PROCEDURE [dbo].[CorreoRequisitor]
@IdSolicitudPedido INT,
@IdProveedor INT
AS
BEGIN

    SELECT u.Nombre, sp.MotivoUrgencia, ac.NombreAreaContractual, u.Correo, sp.IdUsuarioSolicitante, U.Activo AS ExisteSolicitante
    FROM dbo.MM_SolicitudPedido sp (NOLOCK)
        INNER JOIN dbo.TA_Operacion tao (NOLOCK)
            ON sp.IdSolicitudPedido = tao.IdDocumento 
			AND SP.IdUsuarioSolicitante IS NOT NULL --> SOLO SE ENVIA SI REQUISICIÓN TIENE SOLICITANTE
			AND tao.IdTipoOperacion = 2 --> CTE SOLITITUD DE PEDIDO			
        INNER JOIN Adinco.dbo.CO_Contrato c (NOLOCK)
            ON sp.IdContrato = c.IdContrato
        INNER JOIN Adinco.dbo.CO_AreaContractual ac (NOLOCK)
            ON  c.IdAreaContractual = ac.IdAreaContractual
        LEFT JOIN dbo.S_Usuario u (NOLOCK)
            ON sp.IdUsuarioSolicitante = u.IdUsuario			
    WHERE tao.IdDocumento = @IdSolicitudPedido
          AND sp.IdProveedor = @IdProveedor



END;


