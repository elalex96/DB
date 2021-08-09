create PROC sp_SC_InsertarSubContrato
@pIdSubContrato	int out,
@pIdSubContratista	int,
@pIdContratista	int,
@pNumeroSubContrato	varchar(30),
@pObjeto varchar(300),
@pIdPedido INT,
@pIdContrato int,
@pCreadoPor	INT,
@pPrefijoOT VARCHAR(13),
@pFechaInicio DateTime=null,
@pFechaFin DateTime = null,
@pError varchar(250) = '' out
AS
BEGIN

	DECLARE @IdSCMaterial int,
		@IdMoneda int

	Select @IdMoneda = ped.IdMoneda
	FROM Petrovendor.dbo.MM_PedidoDetalle ped
	INNER JOIN Petrovendor.dbo.MM_Material mat ON mat.IdMaterial = ped.IdMaterial
	WHERE ped.IdPedido = @pIdPedido

	

	BEGIN TRY	

	

	if exists(
		select 1
		from SC_Subcontrato 
		where IdContratista = @pIdContratista and
		NumeroSubContrato = @pNumeroSubContrato and
		IsActivo = 1 and
		IdContrato = @pIdContrato
	)
	begin 
		set @pError = '[WARNING] Ya existe un SubContrato con el mismo número de subcontrato'; 
		return
	END
    

	if exists(
		select 1
		from SC_Subcontrato 
		where PrefijoOT = RTRIM(@pPrefijoOT) and
		IsActivo = 1 and
		IdContrato = @pIdContrato
	)
	begin 
		set @pError = '[WARNING] Ya no es posible utilizar el Prefijo para la OT'; 
		return
	end
	
	BEGIN TRAN

	select @pIdSubContrato = isnull(max(IdSubContrato),0)+1 from SC_Subcontrato

	insert into SC_Subcontrato(IdSubContrato,
		IdSubContratista,
		IdContratista,
		NumeroSubContrato,
		CreadoPor,
		CreadoEl,
		IsActivo,
		IsEliminado,
		Objeto,
		IdPedido,
		PrefijoOT,
		IdContrato,
		IdMoneda,
		FechaInicio,
		FechaFin)
	values(
		@pIdSubContrato,
		@pIdSubContratista,
		@pIdContratista,
		@pNumeroSubContrato,
		@pCreadoPor,
		getdate(),
		1,
		0,
		@pObjeto,
		@pIdPedido,
		@pPrefijoOT,
		@pIdContrato,
		@IdMoneda,
		@pFechaInicio,
		@pFechaFin
	)


	SELECT @IdSCMaterial = ISNULL(MAX(IdSCMaterial),0) + 1
	FROM 	SC_Materiales	

	INSERT INTO dbo.SC_Materiales
	(
	    IdSCMaterial,
	    IdSubContrato,
	    Concepto,
	    IdMaestro,
	    IdUnidad,
	    Cantidad,
	    PrecioUnitario,
	    Importe,
	    Descripcion,
	    DescripcionCorta,
	    CreadoPor,
	    CreadoEl,
	    ModificadoPor,
	    ModificadoEl,
	    IdServicio
	)		
	SELECT  ROW_NUMBER() OVER(ORDER BY ped.IdMaterial ASC)+@IdSCMaterial AS ID,
	@pIdSubContrato,
	ped.IdMaterial,
	ped.IdMaterial,
	ISNULL(MAT.IdUnidad,10011) /****SI VIENE NULO PONER UNIDAD SERVICIO PV_MM_MaterialUnidad POR DEFAULT*/,
	sum(ped.Cantidad),
	PED.PrecioUnitario,
	sum(ped.Cantidad)* ped.PrecioUnitario,
	MAT.DescripcionCorta,
	mat.DescripcionLarga,
	@pCreadoPor,
	GETDATE(),
	NULL,
	NULL,
	NULL
	FROM Petrovendor.dbo.MM_PedidoDetalle ped
	INNER JOIN Petrovendor.dbo.MM_Material mat ON mat.IdMaterial = ped.IdMaterial
	WHERE ped.IdPedido = @pIdPedido
	group by ped.IdMaterial,MAT.IdUnidad,PED.PrecioUnitario,MAT.DescripcionCorta,mat.DescripcionLarga

	


	/**************En base al pedido, insertar el presupuesto para el subcontrato***********/

	DECLARE @pIdPresupuesto INT,
		@pIdSubContratoPresupuesto int
	
	SELECT @pIdPresupuesto = ISNULL(LP.IdPresupuesto,0)
	FROM Petrovendor.dbo.MM_Pedido ped
	INNER JOIN Petrovendor.dbo.MM_SolicitudPedido solP ON solP.IdSolicitudPedido = ped.IdSolicitudPedido
	inner join Petrovendor.dbo.MM_SolicitudPedidoDetalle solPD on solPD.IdSolicitudPedido = solP.IdSolicitudPedido
	INNER JOIN Petrovendor.dbo.[MM_SolicitudPedidoDetalleLineaPresupuesto] lp2 on lp2.IdSolicitudPedidoDetalle = solPD.IdSolicitudPedidoDetalle
	INNER JOIN dbo.CO_LineaPresupuestoMes lp ON lp.IdLineaPresupuestoMes = lp2.IdLineaPresupuesto
	WHERE IdPedido = @pIdPedido

	SELECT @pIdSubContratoPresupuesto = ISNULL(MAX(IdSubContratoPresupuesto),0) + 1
	FROM dbo.SC_Presupuesto	

	INSERT INTO dbo.SC_Presupuesto
	(
	    IdSubContratoPresupuesto,
	    IdSubContrato,
	    IdPresupuesto,
	    CreadoPor,
	    CreadoEl
	)
	VALUES
	(   
	
		@pIdSubContratoPresupuesto,        -- IdSubContratoPresupuesto - int
	    @pIdSubContrato,        -- IdSubContrato - int
	    @pIdPresupuesto,        -- IdPresupuesto - int
	    @pCreadoPor,        -- CreadoPor - int
	    GETDATE() -- CreadoEl - datetime
	    )
	

	exec p_SC_Materiales_Gen @pIdSubContrato,0


	COMMIT TRAN


	END TRY
	BEGIN CATCH
		ROLLBACK TRAN
		set @pError = '[ERROR]'+ ERROR_MESSAGE()
	END CATCH
	

END





