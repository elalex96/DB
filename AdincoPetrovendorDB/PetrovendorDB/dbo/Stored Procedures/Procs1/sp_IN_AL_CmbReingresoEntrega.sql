
Create Proc [dbo].[sp_IN_AL_CmbReingresoEntrega]
@pIdAlmacen int
As

	select IdMovimientoDetalle, 
			IdMaterial,
			MaterialDes,
			MaterialDesLarga
	from vw_IN_AL_Movimientos v
	where v.IdAlmacen = @pIdAlmacen
