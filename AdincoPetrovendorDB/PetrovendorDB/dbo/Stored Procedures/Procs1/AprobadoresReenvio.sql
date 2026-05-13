USE [Petrovendor]
GO
  IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'AprobadoresReenvio'
)
DROP PROCEDURE AprobadoresReenvio;   
GO 
/****** Object:  StoredProcedure [dbo].[AprobadoresReenvio]    Script Date: 21/03/2024 12:27:35 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel Ac
-- Create date: 21/03/2024
-- Description:	Consultar detalle de requisición y lista de aprobadores cuando este activos
-- =============================================
CREATE PROCEDURE [dbo].[AprobadoresReenvio]
@IdSolicitudPedido INT,
@IdProveedor INT
AS
BEGIN

    SELECT t.IdOperacion,
           f.IdTipoFlujo,
           ac.NombreAreaContractual,
           t.IdAprobador,
           u.Correo,
		   u.Nombre,
		   t.NoSecuencia,
		   tao.Descripcion,
		   'Solicitud de pedido editada'
    FROM dbo.MM_SolicitudPedido sp (NOLOCK)
        INNER JOIN dbo.TA_Operacion tao (NOLOCK)
            ON sp.IdSolicitudPedido = tao.IdDocumento 
			AND tao.IdTipoOperacion = 2
        INNER JOIN dbo.TA_Tarea t (NOLOCK)
            ON tao.IdOperacion = t.IdOperacion 
        INNER JOIN dbo.TA_FlujoTarea f (NOLOCK)
            ON tao.IdFlujoTarea = f.IdFlujoTarea 
        INNER JOIN Adinco.dbo.CO_Contrato c (NOLOCK)
            ON sp.IdContrato = c.IdContrato 
        INNER JOIN Adinco.dbo.CO_AreaContractual ac (NOLOCK)
            ON c.IdAreaContractual = ac.IdAreaContractual
        LEFT JOIN dbo.S_Usuario u (NOLOCK)
            ON t.IdAprobador = u.IdUsuario
			AND U.Activo = 1 --> Solo notificar a usuarios activos 
    WHERE tao.IdDocumento = @IdSolicitudPedido
          AND sp.IdProveedor = @IdProveedor


END;