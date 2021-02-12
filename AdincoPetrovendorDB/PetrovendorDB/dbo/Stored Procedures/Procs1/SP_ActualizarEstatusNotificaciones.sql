use Petrovendor

go

if exists (select * from sys.procedures where name = 'SP_ActualizarEstatusNotificaciones')
begin
	drop proc SP_ActualizarEstatusNotificaciones
end

go
-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <19/12/19>
-- Description:	<Consulta y actualiza el estatus de las notificaciones dependiendo el tipo>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ActualizarEstatusNotificaciones]
@IdProveedor INT,
@IdUsuario INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	create table #Operacion 
	(
		IdOperacion			INT,
		IdTabla				INT,
		IdTipo				INT,
		IdEstatusOperacion	int
	)

	INSERT INTO #Operacion
	(		IdOperacion,
			IdTabla,
			IdTipo,
			IdEstatusOperacion
	)
	SELECT		N.IdOperacion,
				N.IdTabla,
				N.IdTipoNotificacion,
				O.IdEstatusOperacion
	FROM		dbo.Notificacion		N
	inner join	dbo.TA_Operacion		O
	on			N.IdOperacion			=	O.IdOperacion
	WHERE	N.IdProveedor				=	@IdProveedor
	--AND N.IdTipoNotificacion <> 8 -- aprobacion carta CN/ no tiene ta_operacion
	AND N.Activo = 1

	
	--select		n.* 
	--from		Notificacion	n
	
	
	UPDATE		dbo.Notificacion
	SET			dbo.Notificacion.Activo		=	0
	from		dbo.Notificacion			N
	inner join	#Operacion					O
	on			O.IdTipo					=	N.IdTipoNotificacion
	and			O.IdTabla					=	N.IdTabla
	and			O.IdEstatusOperacion		<>	1	-- significa que cambio el estatus
	where		IdTipoNotificacion			
	in			(
					4,	--	aprobación de requisición
					5,	--	aprobación de factura
					6,	--	aprobación de pedido
					7,	-- aprobación de compra directa
					9	-- aprobación de comprobante
				)

	
	UPDATE		dbo.Notificacion
	SET			dbo.Notificacion.Activo		=	0
	from		dbo.Notificacion			N
	inner join	#Operacion					O
	on			O.IdTipo					=	N.IdTipoNotificacion
	and			O.IdTabla					=	N.IdTabla
	and			O.IdEstatusOperacion		=	1		-- cambio de estatus "sin flujo" a pendiente
	where		IdTipoNotificacion			
	in			(
					1,	-- factura sin flujo de aprobación asignado
					2	-- comprobante sin flujo de aprobación asignado
				)
	
	--select		count(*)
	--from		dbo.Notificacion	N
	--inner join	#Operacion			O
	--on			O.IdTipo			=	N.IdTipoNotificacion
	--and			O.IdTabla			=	N.IdTabla
	--and			O.IdEstatusOperacion	<>	1
	--where		IdTipoNotificacion	=	8

	--select	count(*)
	--from	dbo.Notificacion
	--WHERE	IdTipoNotificacion	= 8 -- aprobación de requisición
	--AND 
	--IdTabla IN
	--(
	--	SELECT		N.IdTabla
	--	FROM		#Operacion				N
	--	WHERE		N.IdEstatusOperacion	<>	1 -- significa que cambio el estatus
	--	AND			N.IdTipo				=	8
	--)



	--SELECT		N.IdTabla,
	--			N.IdTipo,
	--			N.IdEstatusOperacion
	--FROM		#Operacion				N
	
	--ON			N.IdOperacion			=	O.IdOperacion
	--WHERE		O.IdEstatusOperacion	<>	1 -- significa que cambio el estatus
	--AND		N.IdTipo				=	4 

	-- APROBACIONES
/*
	-- requisición
	UPDATE	dbo.Notificacion
	SET		Activo				= 0
	WHERE	IdTipoNotificacion	= 4 -- aprobación de requisición
	AND 
	IdTabla IN
	(
		SELECT		N.IdTabla
		FROM		#Operacion				N
		WHERE		N.IdEstatusOperacion	<>	1 -- significa que cambio el estatus
		AND			N.IdTipo				=	4 
	)

	-- pedido
	UPDATE	dbo.Notificacion
	SET		Activo				= 0
	WHERE	IdTipoNotificacion	= 6 -- aprobación de pedido
	AND 
	IdTabla IN
	(
		SELECT		N.IdTabla
		FROM		#Operacion				N
		WHERE		N.IdEstatusOperacion	<>	1 -- significa que cambio el estatus
		AND			N.IdTipo				=	6 
	)

	-- factura
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 5 -- aprobación de factura
	AND 
	IdTabla IN
	(
		SELECT		N.IdTabla
		FROM		#Operacion N
		WHERE		N.IdEstatusOperacion <> 1 -- significa que cambio el estatus
		AND			N.IdTipo = 5 
	)

	-- pedimento comprobante
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 9 -- aprobación de comprobante
	AND 
	IdTabla IN
	(
		SELECT	N.IdTabla
		FROM	#Operacion N
		WHERE	N.IdEstatusOperacion <> 1 -- significa que cambio el estatus
		AND		N.IdTipo = 9 
	)

	-- compra directa
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 7 -- aprobación de compra directa
	AND 
	IdTabla IN
	(
		SELECT
		N.IdTabla
		FROM	#Operacion N
		WHERE	N.IdEstatusOperacion	<>	1 -- significa que cambio el estatus
		AND		N.IdTipo				=	7 
	)
*/

/*	-- factura sin flujo
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 1 -- factura sin flujo de aprobación asignado
	AND 
	IdTabla IN
	(
		SELECT	N.IdTabla
		FROM	#Operacion				N
		WHERE	N.IdEstatusOperacion	= 1 -- cambio de estatus "sin flujo" a pendiente
		AND		N.IdTipo				= 1 
	)

	-- comprobante sin flujo
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 2 -- comprobante sin flujo de aprobación asignado
	AND 
	IdTabla IN
	(
		SELECT		N.IdTabla
		FROM		#Operacion				N
		WHERE		N.IdEstatusOperacion	= 1 -- cambio de estatus "sin flujo" a pendiente
		AND			N.IdTipo				= 2 
	)
*/
	-- carta CN
	UPDATE dbo.Notificacion
	SET Activo = 0
	WHERE IdTipoNotificacion = 8 -- aprobación carta CN
	AND 
	IdTabla IN
	(
		SELECT		AP.IdAceptacionPedido
		FROM		dbo.MM_AceptacionCartaPCN	AP
		INNER JOIN	#Operacion N
		ON			AP.IdAceptacionPedido		=	N.IdOperacion
		WHERE		AP.IdEstatus				<> 1 -- significa que cambio el estatus
		AND			N.IdTipo					=	8 
		GROUP BY	AP.IdAceptacionPedido
	)

	SELECT 'success';
	
END


go

--exec SP_ActualizarEstatusNotificaciones @IdProveedor=516,@IdUsuario=2572