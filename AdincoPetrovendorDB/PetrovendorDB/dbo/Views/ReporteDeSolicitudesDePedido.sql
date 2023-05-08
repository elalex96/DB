CREATE VIEW [dbo].[ReporteDeSolicitudesDePedido]
AS
     SELECT C.NumeroContrato,
            AC.NombreAreaContractual,
            PC.RazonSocial AS Operadora,
            SP.IdSolicitudPedido,
            SP.MotivoUrgencia AS Motivo1,
            TSP.TipoSolicitudPedido,
            SP.FechaAlta,
            U.Nombre AS NombreUsuario,
            SP.MotivoUrgencia AS Motivo2,
            TE.Nombre
     FROM MM_SolicitudPedido AS SP
          INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
          INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento = SP.IdSolicitudPedido
          INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion
          LEFT JOIN CC_CentroCosto AS CC ON SP.IdCentroCosto = CC.IdCentroCosto
          INNER JOIN S_Usuario AS U ON SP.IdUsuarioSolicitante = U.IdUsuario
          LEFT JOIN Adinco.dbo.CO_Contrato AS C ON SP.IdContrato = C.IdContrato
          LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON C.IdAreaContractual = AC.IdAreaContractual
          JOIN Adinco.dbo.CO_Contratista CCC ON CCC.IdContratista = C.IdContratista
          JOIN dbo.S_Proveedor PC ON PC.RFC = CCC.RFC COLLATE Modern_Spanish_CI_AS
     WHERE SP.IdProveedor IN(606, 690)
          AND TAO.IdTipoOperacion = 2
          AND ISNULL(SP.Visible, 1) = 1;
