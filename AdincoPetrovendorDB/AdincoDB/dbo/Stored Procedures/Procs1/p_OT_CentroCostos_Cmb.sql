-- p_OT_CentroCostos_Cmb 10038,10
CREATE ALTER proc [dbo].[p_OT_CentroCostos_Cmb]
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
            on cont.IdContratista = c.IdContratista
        inner join petrovendor..s_proveedor prov (NOLOCK)
            on prov.RFC collate SQL_Latin1_General_CP1_CI_AS = cont.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
               and prov.IdProveedor = cc.IdProveedor
        inner join AP_UsuarioCentroCosto ucc (NOLOCK)
            on ucc.IdUsuario = @pUsuarioId
               and ucc.IdCentroCosto = cc.IdCentroCosto
    where cc.IsActivo = 1
    group by cc.IdCentroCosto,
             cc.CentroCosto,
             cc.IdProveedor
    order by cc.CentroCosto

end

