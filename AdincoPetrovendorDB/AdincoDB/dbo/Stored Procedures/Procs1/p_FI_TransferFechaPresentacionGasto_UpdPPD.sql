-- =============================================
-- Author:		Manuel Cruz
-- Create date: 19-08-2019
-- Description:	
-- =============================================
-- Modificado Por: Neri Garcia
-- Fecha: 11 de Agosto del 2022
-- Detalles: Agregado de NOLOCK y Nombrado de Tablas en select
-- =============================================
-- Modificado Por: Reyna olvera
-- Fecha: 10 de Marzo del 2023
-- Detalles: Agregado de gastos solo del contrato y solución de modificación de mes presentación
-- =============================================
CREATE PROCEDURE [dbo].[p_FI_TransferFechaPresentacionGasto_UpdPPD]
    @pIdTransferencia INT,
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
	
    DECLARE @MesPresentacionCGI DATE,
            @FechaPago DATE,
            @FechaMayor DATE;
    DECLARE @pGastosActualizados INT;
    CREATE TABLE #Fechas
    (
        Fecha DATE,
        Tipo INT
    );
    --
    CREATE TABLE #tmpTemp
    (
        IdRegistro INT,
        MesPresentacionCGI DATE,
        IdTransferencia INT,
        IdContrato INT,
        RegistroMesPresentacion DATE
    );
    /**/
    SELECT @MesPresentacionCGI = '1999-01-01',
           @FechaPago = DATEFROMPARTS(YEAR(dbo.FI_Transfer.FechaPago), MONTH(dbo.FI_Transfer.FechaPago), 1)
    FROM dbo.CO_Contrato (NOLOCK)
        JOIN dbo.FI_Transfer (NOLOCK)
            ON dbo.CO_Contrato.IdContrato = dbo.FI_Transfer.IdContrato
    WHERE dbo.CO_Contrato.IdContrato = @IdContrato
          AND dbo.FI_Transfer.IdTransferencia = @pIdTransferencia;
    --
    INSERT INTO #Fechas
    (
        Fecha,
        Tipo
    )
    VALUES
    (@MesPresentacionCGI, 1);
    --
    INSERT INTO #Fechas
    (
        Fecha,
        Tipo
    )
    VALUES
    (@FechaPago, 2);
    --
    SELECT @FechaMayor = MAX(Fecha)
    FROM #Fechas;
    /**/
    INSERT INTO #tmpTemp
    (
        IdRegistro,
        MesPresentacionCGI,
        IdTransferencia,
        IdContrato,
        RegistroMesPresentacion
    )
    SELECT  dbo.CO_Registro.IdRegistro,
           MesPresentacion = dbo.CO_Contrato.MesPresentacionCGI,
           dbo.[FI_Transfer].IdTransferencia,
           dbo.[FI_Transfer].IdContrato,
           MesPresentacionActual = dbo.CO_Registro.MesPresentacion
    FROM dbo.[FI_Transfer] (NOLOCK)
        JOIN dbo.FI_TransferFactura (NOLOCK)
            ON dbo.[FI_Transfer].IdTransferencia = dbo.FI_TransferFactura.IdTransfer
			  AND dbo.[FI_Transfer].IdContrato = @IdContrato
        JOIN dbo.FI_Factura (NOLOCK)
            ON dbo.FI_TransferFactura.IdFactura = dbo.FI_Factura.IdFactura
        JOIN dbo.FI_ComplementoDePago (NOLOCK)
            ON dbo.FI_Factura.IdFactura = dbo.FI_ComplementoDePago.IdFactura
        JOIN dbo.FI_CPDocRelacionado (NOLOCK)
            ON dbo.FI_ComplementoDePago.IdComplementoDePago = dbo.FI_CPDocRelacionado.IdComplementoDePago
        JOIN dbo.FI_Factura FI_Factura_DocRelacionado (NOLOCK)
            ON dbo.FI_CPDocRelacionado.IdDocumento = FI_Factura_DocRelacionado.UUID
        JOIN dbo.CO_Registro (NOLOCK)
            ON FI_Factura_DocRelacionado.IdFactura = dbo.CO_Registro.IdFactura
		JOIN
            dbo.CO_LineaPresupuestoMes WITH (NOLOCK)
                ON CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
        JOIN
            dbo.CO_Presupuesto WITH (NOLOCK)
                ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        JOIN
            dbo.CO_AnioContractual WITH (NOLOCK)
                ON CO_AnioContractual.IdAnioContractual = CO_Presupuesto.IdAnioContractual
                    AND CO_AnioContractual.IdContrato = @IdContrato
        JOIN dbo.CO_Contrato (NOLOCK)
            ON dbo.[FI_Transfer].IdContrato = dbo.CO_Contrato.IdContrato
    WHERE dbo.[FI_Transfer].IdTransferencia = @pIdTransferencia
         AND dbo.CO_Contrato.MesPresentacionCGI IS NOT NULL
          AND dbo.[FI_Transfer].IdContrato = @IdContrato;

    /**/
    SELECT @pGastosActualizados = COUNT(DISTINCT IdRegistro)
    FROM #tmpTemp;
    /**/
    UPDATE CO_Registro
    SET CO_Registro.MesPresentacion = @FechaMayor
    FROM CO_Registro (NOLOCK)
        JOIN #tmpTemp
            ON CO_Registro.IdRegistro = #tmpTemp.IdRegistro
    WHERE CO_Registro.IdRegistro = #tmpTemp.IdRegistro;
    /**/
    SELECT @pGastosActualizados,
           CONVERT(VARCHAR, @FechaMayor, 111);
END;
