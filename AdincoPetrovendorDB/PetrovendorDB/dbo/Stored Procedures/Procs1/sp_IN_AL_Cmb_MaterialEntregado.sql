

-- sp_IN_AL_Cmb_MaterialEntregado 1
Create Proc [dbo].[sp_IN_AL_Cmb_MaterialEntregado]
@pIdAlmacen int
As

	select
			IdMaterial,			
			MaterialDes,
			MaterialDesLarga,
			Unidad
	from vw_IN_AL_Movimientos v
	where v.IdAlmacen = @pIdAlmacen and
	v.IdTipoMovimiento = 2
	group by IdMaterial,
			MaterialDes,
			MaterialDesLarga,
			Unidad
