-- p_OT_CentroCostos_Cmb 10038,10
CREATE proc [dbo].[p_OT_CentroCostos_Cmb]
    @pIdContrato int,
    @pUsuarioId int
as
begin
    select cc.IdCentroCosto,
           cc.CentroCosto,
           cc.IdProveedor
    from petrovendor..Cc_centrocosto cc (NOLOCK)
        inner join Adinco..CO_Contrato c (NOLOCK)
            on c.IdContrato = @pIdContrato
        inner join Adinco..CO_Contratista cont (NOLOCK)
            on c.IdContratista = cont.IdContratista  
        inner join petrovendor..s_proveedor prov (NOLOCK)
            on cont.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = prov.RFC collate SQL_Latin1_General_CP1_CI_AS  
               and cc.IdProveedor = prov.IdProveedor 
        inner join AP_UsuarioCentroCosto ucc (NOLOCK)
            on ucc.IdUsuario = @pUsuarioId
               and cc.IdCentroCosto = ucc.IdCentroCosto 
    where cc.IsActivo = 1
    group by cc.IdCentroCosto,
             cc.CentroCosto,
             cc.IdProveedor
    order by cc.CentroCosto

end

