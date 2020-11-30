create view GetTipoDocumento
as
select TD.IdTipoDocumento, TD.NombreTipoDocumento from  S_TipoDocumentoTipoPersona TTP 
inner join S_TipoRegimen TR on TTP.IdTipoRegimen = TR.IdTipoRegimen
inner join S_TipoDocumento TD on TTP.IdTipoDocumento = TD.IdTipoDocumento
where TTP.IdTipoRegimen = 2