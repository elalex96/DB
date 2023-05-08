-- =============================================
-- Author:		Daniel AC
-- Update date: 06-10-2020
-- Description: Se agrego filtro por contrato
-- =============================================
-- p_OT_ObtenerOTConvenio 'ra@smps-sp.com',0
CREATE PROC p_OT_ObtenerOTConvenio
    @pUsuario VARCHAR(250),
    @pAprobada BIT,
    @IdContrato INT
AS
SELECT sol.IdOTSolicitud,
       sol.IdSubContrato,
       sol.Folio,
       sol.FechaInicio,
       sol.FechaFin,
       sol.PlazoEjecucion,
       sol.CreadoPor,
       sol.CreadoEl,
       sol.ModificadoPor,
       sol.ModificadoEl,
       sol.IsActivo,
       sol.IsEliminado,
       sol.IdPresupuesto,
       sol.Objeto,
       sol.IdOTEstatus,
       sol.FechaFinExtendida,
       sol.IdOTEstatusAnt,
       NombrePresupuesto = pre.Nombre,
       subC.IdSubContrato,
       con.IdOTConvenio,
       Moneda = ISNULL(TipoMonedaCorto, 'NO ESPECIFICADO')
FROM [OT_Solicitud] sol
    INNER JOIN CO_Presupuesto pre
        ON pre.IdPresupuesto = sol.IdPresupuesto
    INNER JOIN dbo.SC_SubContrato subC
        ON subC.IdSubContrato = sol.IdSubContrato
    INNER JOIN dbo.PV_Subcontratista SUB
        ON SUB.IdSubcontratista = subC.IdSubContratista
    INNER JOIN Petrovendor.dbo.S_Proveedor prov
        ON prov.RFC COLLATE DATABASE_DEFAULT = SUB.RFC COLLATE DATABASE_DEFAULT
    INNER JOIN OT_Convenio con
        ON con.IdOTSolicitud = sol.IdOTSolicitud
    INNER JOIN AP_Usuario ap
        ON ap.Usuario = RTRIM(@pUsuario)
    INNER JOIN [dbo].[AP_UsuarioCentroCosto] ucc
        ON ucc.IdUsuario = ap.UsuarioID
           AND ucc.IdCentroCosto = sol.IdCentroCosto
    INNER JOIN AP_PerfilUsuario pu
        ON pu.UsuarioID = ap.UsuarioID
    INNER JOIN AP_Perfil per
        ON per.IdPerfil = pu.PerfilID
           AND per.IdContrato = subC.IdContrato
    INNER JOIN Petrovendor.dbo.S_Usuario upet
        ON upet.Correo COLLATE DATABASE_DEFAULT = ap.Usuario COLLATE DATABASE_DEFAULT
    LEFT JOIN Petrovendor.dbo.MM_Pedido ped
        ON ped.IdPedido = subC.IdPedido
    LEFT JOIN Petrovendor.dbo.[PV_TipoMoneda] mon
        ON mon.IdMoneda = ped.IdMoneda
WHERE ISNULL(sol.IsActivo, 0) = 1
      AND ISNULL(sol.IsEliminado, 0) = 0
      AND con.Aprobada = @pAprobada
	  AND subC.IdContrato=@IdContrato
ORDER BY con.IdOTConvenio DESC;


