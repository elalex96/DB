Create Proc [dbo].[sp_SC_InsertarMaterial]
@pIdSCMaterial	int out,
@pIdSubContrato	int,
@pConcepto	varchar(30),
@pIdMaestro	int,
@pIdUnidad	int,
@pIdServicio int,
@pCantidad	decimal(14,2),
@pPrecioUnitario	money,
@pImporte	money,
@pDescripcion	varchar(510),
@pDescripcionCorta	varchar(250),
@pCreadoPor	int
as

	/************VALIDAR QUE NO SE INSERTEN CONCEPTOS DUPLICADOS***************/

	if (
		select count(distinct IdSCMaterial)
		from sc_materiales
		where @pIdSubContrato = IdSubContrato and
		Concepto = @pConcepto
		)
		>0
	begin
		RAISERROR (15600,-1,-1, 'No se puede ingresar un concepto duplicado'); 
		return
	end

	/************Validar que no se intente insertar mas de una vez el servicio para el subcontrato******************/
	if (
		select count(distinct IdSCMaterial)
		from sc_materiales
		where @pIdSubContrato = IdSubContrato and
		IdServicio = @pIdServicio and
		IdMaestro = @pidMaestro
		)
		>0
	begin
		RAISERROR (15600,-1,-1, 'No se puede ingresar un servicio maestro duplicado'); 
		return
	end

	select @pIdSCMaterial = isnull(max(IdSCMaterial),0) + 1
	from sc_materiales
	

	insert into sc_materiales(
		IdSCMaterial,IdSubContrato,Concepto,IdMaestro,IdUnidad,Cantidad,PrecioUnitario,
		Importe,Descripcion,DescripcionCorta,CreadoPor,CreadoEl,IdServicio
	)
	values(
		@pIdSCMaterial,@pIdSubContrato,@pConcepto,@pIdMaestro,@pIdUnidad,@pCantidad,@pPrecioUnitario,
		@pImporte,@pDescripcion,@pDescripcionCorta,@pCreadoPor,getdate(),@pIdServicio
	)