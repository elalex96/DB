
Create Proc [dbo].[sp_IN_AL_Cmb_MaterialEntregados]
@pIdAlmacen int
As

	select
			IdMaterial,
			MaterialDes,
			MaterialDesLarga
	from vw_IN_AL_Movimientos v
	where v.IdAlmacen = @pIdAlmacen
	group by IdMaterial,
			MaterialDes,
			MaterialDesLarga
