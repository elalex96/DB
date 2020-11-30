-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- p_OT_ObtenerOTConvenio 'ra@smps-sp.com',0
CREATE Proc p_OT_ObtenerOTConvenio
@pUsuario varchar(250),
@pAprobada bit
as

SELECT 	sol.IdOTSolicitud,
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
NombrePresupuesto=pre.Nombre,
subC.IdSubContrato,
con.IdOTConvenio,
Moneda = isnull(TipoMonedaCorto,'NO ESPECIFICADO')
FROM [OT_Solicitud] sol
inner join CO_Presupuesto pre on pre.IdPresupuesto = sol.IdPresupuesto
INNER JOIN dbo.SC_SubContrato subC ON subC.IdSubContrato = sol.IdSubContrato
INNER JOIN dbo.PV_Subcontratista SUB ON SUB.IdSubcontratista = subc.IdSubContratista
INNER JOIN Petrovendor.dbo.S_Proveedor prov ON  prov.RFC COLLATE DATABASE_DEFAULT = sub.RFC  COLLATE DATABASE_DEFAULT
inner join OT_Convenio con on con.IdOTSolicitud = sol.IdOTSolicitud
inner join AP_Usuario ap on ap.Usuario = rtrim(@pUsuario)
inner join [dbo].[AP_UsuarioCentroCosto] ucc on ucc.IdUsuario = ap.UsuarioID and
											ucc.IdCentroCosto = sol.IdCentroCosto
inner join AP_PerfilUsuario pu on pu.UsuarioID = ap.UsuarioID
inner join AP_Perfil per on per.IdPerfil = pu.PerfilID and
				per.IdContrato = subC.IdContrato
inner join Petrovendor.dbo.S_Usuario upet on upet.Correo COLLATE DATABASE_DEFAULT = ap.Usuario COLLATE DATABASE_DEFAULT
left join Petrovendor.dbo.MM_Pedido ped on ped.IdPedido = subC.IdPedido 
left join Petrovendor.dbo.[PV_TipoMoneda] mon on mon.IdMoneda = ped.IdMoneda
where isnull(sol.isActivo,0) = 1 and isnull(sol.isEliminado,0) = 0 and        
		con.Aprobada = @pAprobada        
Order by con.IdOTConvenio desc



