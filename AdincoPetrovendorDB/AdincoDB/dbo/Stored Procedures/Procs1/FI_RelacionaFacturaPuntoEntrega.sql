CREATE PROCEDURE [dbo].[FI_RelacionaFacturaPuntoEntrega]
	-- Add the parameters for the stored procedure here
	@idFactura int,
	@idPuntoEntrega int,
	@idContrato int,
	@idUsuario int,
	@fechaMesDiaAnio date,
	@hidrocarburo int
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 13/04/2018
-- Description:	Relaciona Las facturas con el punto de entrega 
-- =============================================
-- 20180611	BAAC	Se modifica para ligar las comercializaciones con la factura por punto de entrega
-- =============================================	
-- 24072018	JMCD	Se modifica para ligar las comercializaciones en donde se produjo gas (condensable), las cuales son marcadas con un bit = 1 
--					en la columna EsCondensable de la tabla COM_OperacionComercializacion, que es marcado al generar las comercializaciones
--					si en la cromatografía hay volumen de n C5, I C5 Y C6+
-- =============================================	
AS
BEGIN
	SET NOCOUNT ON

	CREATE TABLE #TipoHidrocarburo
	(
		IdTipoHidrocarburo	INT,
		IdHidrocarburo		INT
	)

	DECLARE @ContProduct INT
    DECLARE @cont INT
    DECLARE @GasNoAsociado as bit


    select @GasNoAsociado  = GasNoAsociado     from CO_Contrato where IdContrato= @idContrato

	IF @hidrocarburo = 1000	-- Gas
	BEGIN
		INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10002, 1000)
		INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10003, 1000)
		INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10004, 1000)
		INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10005, 1000)
		--IF @GasNoAsociado   = 1
		--begin
		--INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo ) VALUES (10001)
		--end

	END
	ELSE
	BEGIN
		IF @hidrocarburo = 1001	-- Aceite
		BEGIN
			INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10000, 1001)
        END
		ELSE
        BEGIN
			INSERT INTO #TipoHidrocarburo ( IdTipoHidrocarburo, IdHidrocarburo ) VALUES (10001, 1002)
        END
	END
    
	-- SE BUSCAN LAS COMERCIALIZACIONES PARA EL PUNTO DE ENTREGA PARA ASIGNARLES LA FACTURA
	
	--/*Si el hidrocarburo es 1002 Condensable se actualiza la comercializacion con el bit=1 de EsCondensable*/
	--IF @hidrocarburo = 1002
	--BEGIN
	--	UPDATE C	
	--	SET IdFactura = @idFactura
	--	FROM
	--		COM_OperacionComercializacion	C
	--	JOIN
	--		#TipoHidrocarburo	T
	--		ON	C.IdTipoHidrocarburo	=	T.IdTipoHidrocarburo
	--	WHERE
	--		IdContrato	=	@idContrato
	--		AND	MesReporte	=	@fechaMesDiaAnio
	--		AND PuntoEntregaID = @idPuntoEntrega
	--		AND C.EsCondensable = 1
	--END
	--ELSE 
	--BEGIN
		--UPDATE C	
		--	SET IdFactura = @idFactura
		--FROM
		--	COM_OperacionComercializacion	C
		--JOIN
		--	#TipoHidrocarburo	T
		--	ON	C.IdTipoHidrocarburo	=	T.IdTipoHidrocarburo
		--WHERE
		--	IdContrato	=	@idContrato
		--	AND	MesReporte	=	@fechaMesDiaAnio
		--	AND PuntoEntregaID = @idPuntoEntrega
    --END

	--IF @hidrocarburo = 1000	-- Gas	SE LIGAN LAS FACTURAS DE CONDENSABLE
	--BEGIN
	--	UPDATE C	
	--		SET IdFactura = @idFactura
	--	FROM
	--		COM_OperacionComercializacion	C
	--	WHERE
	--		IdContrato	=	@idContrato
	--		AND	MesReporte	=	@fechaMesDiaAnio
	--		AND PuntoEntregaID = @idPuntoEntrega
	--		AND C.IdTipoHidrocarburo = 10001
	--		AND C.EsCondensable = 1
	--END

	SELECT @ContProduct=idfacturaPuntoEntrega 
	FROM  FI_FacturaPuntoEntrega 
	WHERE productoid=@hidrocarburo and MesReporte=@fechaMesDiaAnio and PuntoEntregaid=@idPuntoEntrega

	IF (@ContProduct>=1)--Checa si ya hay producto facturado para esa fecha y ese punto de entrega, si no hay puede entrar para insertar con la factura
	BEGIN
		SELECT 2
	END
	ELSE
	BEGIN
		SELECT @cont= idfacturaPuntoEntrega
		FROM
			FI_FacturaPuntoEntrega FP
		JOIN
			FI_Factura F on FP.idFactura =f.idFactura
		WHERE
			FP.idFactura	=	@idFactura
			AND f.idContrato	=	@idContrato

		IF (@cont>=1)
		BEGIN
		--Checa si la factura ya esta insertada a algunos datos, si ya esta insertada,modifica los datos
			UPDATE  FI_FacturaPuntoEntrega
				SET PuntoEntregaId	=	@idPuntoEntrega,
					ModificadoPor	=	@idUsuario,
					ModificadoEl	=	GETDATE(),
					ProductoId	=	@hidrocarburo,
					MesReporte	=	@fechaMesDiaAnio
			WHERE idFactura=@idFactura 
				SELECT 1
		END 
		ELSE 
		BEGIN 
			INSERT INTO FI_FacturaPuntoEntrega (idFactura,PuntoEntregaId,ProductoId,MesReporte,CreadoPor,CreadoEl,Activo )
			VALUES (@idFactura,@idPuntoEntrega,@hidrocarburo,@fechaMesDiaAnio,@idUsuario,GETDATE(),1);
				SELECT 1
		END
	END

-- SE LIGAN LAS FACTURAS CON LAS COMERCIALIZACIONES EN CASO DE QUE EXISTAN PARA GAS, PETROLEO Y CONDENSADO
	UPDATE C	
		SET IdFactura = FP.idFactura
	FROM
		COM_OperacionComercializacion	C
	JOIN
		#TipoHidrocarburo	T
		ON	C.IdTipoHidrocarburo	=	T.IdTipoHidrocarburo
	JOIN
		FI_FacturaPuntoEntrega	FP
		ON	C.PuntoEntregaID	=	FP.PuntoEntregaId
		AND	C.MesReporte	=	FP.MesReporte
		AND	T.IdHidrocarburo	=	FP.ProductoId
	WHERE
		C.IdContrato	=	@idContrato
		AND	C.MesReporte	=	@fechaMesDiaAnio
--			AND C.PuntoEntregaID = @idPuntoEntrega

	-- SE LIGAN LAS FACTURAS DE CONDENSABLE
	UPDATE C	
		SET IdFactura = FP.idFactura
	FROM
		COM_OperacionComercializacion	C
	JOIN
		FI_FacturaPuntoEntrega	FP
		ON	C.PuntoEntregaID	=	FP.PuntoEntregaId
		AND	C.MesReporte	=	FP.MesReporte
		AND	FP.ProductoId	=	1000
	WHERE
		C.IdContrato	=	@idContrato
		AND	C.MesReporte	=	@fechaMesDiaAnio
		--AND C.PuntoEntregaID = @idPuntoEntrega
		AND C.IdTipoHidrocarburo = 10001
		AND C.EsCondensable = 1

END

