				   
CREATE PROCEDURE [dbo].[SP_OCD_EdicionCompraDirectaContenidoNacional]
	-- Add the parameters for the stored procedure here
	@IdCDCN						INT,
	@IdContrato					INT,
	@IdProveedor				INT,
	@IdFactura					INT,
	@IdPedido					INT,
	@DescripcionBienesServicios NVARCHAR(MAX),
	@ValorFactura				FLOAT,
	@PCN						FLOAT,
	@IdActividadBS				INT,
	@ClasificacionSH			INT,
	@IdUsuario					INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


	IF @IdActividadBS = 0
	BEGIN
	    SET @IdActividadBS = NULL;
	END
	    
		UPDATE	dbo.CN_CompraDirecta
		SET		IdContrato					=	@IdContrato,
				IdProveedor					=	@IdProveedor,
				IdFactura					=	@IdFactura,
				IdPedido					=	@IdPedido,
				DescripcionBienesServicios	=	@DescripcionBienesServicios,
				ValorFactura				=	@ValorFactura,
				PCN							=	@PCN,
				IdActividadBS				=	@IdActividadBS,
				ClasificacionSH				=	@ClasificacionSH,
				ModificadoEl				=	GETDATE(),
				ModificadoPor				=	@IdUsuario
		WHERE	IdCDCN						=	@IdCDCN;


	SELECT		CNCD.IdCDCN,
				IdActividadBS						=		ISNULL(CNCD.IdActividadBS,0),
				CNCD.DescripcionBienesServicios,
				CNCD.PCN,
				CNCD.ValorFactura, 
				CNCD.ClasificacionSH
	into		#tmp
	FROM		dbo.CN_CompraDirecta				CNCD
	LEFT JOIN	dbo.MM_BS_Actividad					BS 
	ON			BS.IdActividad						=		CNCD.IdActividadBS
	LEFT JOIN	dbo.CN_ClasificacionContenidoSH		SH
	ON			SH.IdClasificacionSH				=		CNCD.IdCDCN
	WHERE		CNCD.IdPedido						=		@IdPedido
	AND			CNCD.IdFactura						=		@IdFactura
	AND			CNCD.IdProveedor					=		@IdProveedor
	AND			CNCD.IdContrato						=		@IdContrato
	GROUP BY	CNCD.IdCDCN,
				CNCD.IdActividadBS,
				CNCD.DescripcionBienesServicios,
				CNCD.PCN,
				CNCD.ValorFactura,
				CNCD.ClasificacionSH

	declare @totalFacturas float
	select @totalFacturas = sum(ValorFactura) from #tmp
	
	select		IdCDCN,
				IdActividadBS,
				DescripcionBienesServicios,
				PCN,
				ValorFactura, 
				ClasificacionSH, 
				Porcentaje = (ValorFactura*PCN)/@totalFacturas*100 
	into		#tmp2
	from		#tmp

	--select * from #tmp
	--select * from #tmp2

	declare		@NewPCN float
	select		@NewPCN = sum(Porcentaje)/100
	from		#tmp2

	--select		@NewPCN

	update	Petrovendor.dbo.co_registro 
	set		PCN			= @NewPCN
	where	IdFactura	= @IdFactura

	--select PCN, * from Adinco.dbo.co_registro	where	IdRegistro = 66066

	update		Adinco.dbo.co_registro
	set			Adinco.dbo.co_registro.PCN		=		@NewPCN
	from		CO_Registro						reg
	inner join	CO_RelacionRegistroAdinco		rel
	on			reg.IdRegistro					=		rel.IdRegistroPetrovendor
	inner join	Adinco.dbo.co_registro			areg
	on			areg.IdRegistro					=		rel.IdRegistroAdinco
	where		reg.IdFactura					=		@IdFactura

	--select PCN, * from Adinco.dbo.co_registro	where	IdRegistro = 66066

	--select		reg.PCN, 
	--			rel.IdRegistroAdinco
	--from		CO_Registro						reg
	--inner join	CO_RelacionRegistroAdinco		rel
	--on			reg.IdRegistro					=	rel.IdRegistroPetrovendor
	--where		reg.IdFactura					=	@IdFactura


	

	SELECT @IdCDCN AS RegistroActualizado;

END

