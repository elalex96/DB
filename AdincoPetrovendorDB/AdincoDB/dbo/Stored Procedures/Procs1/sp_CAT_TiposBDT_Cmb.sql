
create proc sp_CAT_TiposBDT_Cmb
as
begin
	select	t.IdTipoBDT,
			t.TipoBDT
	from	CAT_TiposBDT	t
end
