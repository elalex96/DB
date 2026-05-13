USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'MM_SP_EnvioDeGastoAdinco'
)
    DROP PROCEDURE MM_SP_EnvioDeGastoAdinco;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Author:  <DANIEL AC>  
-- Create date: 01/10/2019  
-- Description: Se  removio insertado de XML en Adinco   
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: 28/10/2019  
-- Description: se agrego la bitacora de pase adinco  
-- =============================================  
-- Author:  <Alexander Gomez>  
-- Create date: 07/04/2020
-- Description: se valida la aprobacion de la factura para el envio de gasto  
-- =============================================  
-- Author:		<Luis David>
-- UPDATED at: <11/04/2022>
-- Description:	<Clasificación gasto en mes presentación corriente Amatitlán (Issue#1730)>
-- =============================================
-- Author:		<Luis David>
-- Create date: <15/06/2022>
-- Description:	<Se valida si la factura es de Murphy para así agregar la linea presupuesto 241612 (Issue #1865 Petrovendor)>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <28/07/2022>
-- Description:	<Se agrega la cuenta de sector de hidrocarburos para amatitlan (Issue#1954)>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <12/02/2024>
-- Description:	<Se eliminan los datos fijos del pase de gasto de amatitlan y optimizaciones (Issue#2673)>
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_EnvioDeGastoAdinco]
@idFacturaP INT,
@IdFacturaAdinco INT,
/*--------------------parametros contrato  --------------------*/
@IdContrato INT = NULL,
@IdUsuario INT = NULL,
@FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/

AS
BEGIN
    DECLARE @IdRegistroAdinco INT,
            @Contador INT = 1,
            @IdRegistro INT,
            @Cuenta INT,
            @XMLAdinco INT,
            @XMLPetrovendor INT,
            @EstatusAprobacionFactura INT,
			@MontoRegistro FLOAT,
			@IdUsuarioADINCO INT;

	DECLARE @RFC VARCHAR(300) = (SELECT TOP 1 CTA.RFC FROM Adinco..CO_CONTRATO AS CTO (NOLOCK)
									JOIN ADINCO..CO_CONTRATISTA AS CTA (NOLOCK)
										ON CTO.IDCONTRATISTA = CTA.IDCONTRATISTA 
									JOIN FI_FACTURA AS F (NOLOCK)
										ON CTO.IDCONTRATO = F.IDCONTRATO
									WHERE F.IDFACTURA = @idFacturaP);

	DECLARE @Tabla TABLE (Id INT IDENTITY, idRegistro INT);

	SET @IdUsuarioADINCO = (SELECT IdUsuarioADINCO FROM S_Usuario (NOLOCK) WHERE IdUsuario = @IdUsuario);

    ---ESTATUS DE APROBACION DE LA FACTURA
	
    SELECT TOP 1
           @EstatusAprobacionFactura = TA.IdEstatusOperacion
    FROM dbo.MM_AceptacionFactura AS AF (NOLOCK)
        LEFT JOIN dbo.TA_Operacion AS TA (NOLOCK)
            ON AF.IdAceptacionFactura = TA.IdDocumento
               AND TA.IdTipoOperacion = 10
    WHERE AF.IdFactura = @idFacturaP
    ORDER BY AF.CreadoEl DESC

    INSERT INTO @Tabla (idRegistro)
    SELECT pr.IdRegistro
    FROM Petrovendor.dbo.CO_Registro pr (NOLOCK)
    WHERE pr.IdFactura = @idFacturaP;

    SELECT @Cuenta = COUNT(1)
    FROM @Tabla;

    --Se copian todos los registros de gastos con los que cuenta esta factura  
    WHILE (@Contador <= @Cuenta)
    BEGIN
        SELECT @IdRegistro = idRegistro
        FROM @Tabla
        WHERE Id = @Contador;

        --VALIDACION DE VERIFICACION DE EXISTENCIA DE GASTO POR ACEPTACION DE PEDIDO DETALLE
        SELECT @IdRegistroAdinco = ar.IdRegistro
        FROM Adinco.dbo.CO_Registro ar (NOLOCK)
            INNER JOIN dbo.CO_Registro r (NOLOCK)
                ON ar.IdAceptacionPedidoDetalle = r.IdAceptacionPedidoDetalle
        WHERE r.IdRegistro = @IdRegistro

        IF (ISNULL(@IdRegistroAdinco, 0) = 0)
        BEGIN
			--SE COMPARA EL RFC(AMATITLÁN) PARA CLASIFICAR SU GASTO EN EL MES PRESENTACIÓN CORRIENTE
			IF @RFC = 'PAM140722DK6'
			BEGIN

				INSERT INTO Adinco.dbo.CO_Registro
				(
					IdPrograma,
					IdFactura,
					MontoRegistro,
					InicioEjecucion,
					FinEjecucion,
					Comentarios,
					MesPresentacion,
					IdEstado,
					IdUsuarioCreadoPor,
					FecMovto,
					IdInstalacion,
					IdCatalogoCuentasSH,
					Poliza,
					IsEditable,
					CostosAtribuiblesAdministracion,
					PCN,
					IdGastoRubro,
					IdCBSISH,
					IdAceptacionPedidoDetalle
				)
				SELECT pr.IdLineaPresupuestoMes,
					   @IdFacturaAdinco,
					   pr.MontoRegistro,
					   pr.InicioEjecucion,
					   pr.FinEjecucion,
					   pr.Comentarios,
					   CASE WHEN DAY(f.FechaTimbrado) > 20 AND MONTH(f.FechaTimbrado) = 12
								THEN DATEFROMPARTS ( YEAR(DATEADD(YEAR,1,f.FechaTimbrado)), MONTH(DATEADD(MONTH,1,f.FechaTimbrado)), 01 )
							WHEN DAY(f.FechaTimbrado) <= 20 AND MONTH(f.FechaTimbrado) <= 12
								THEN DATEFROMPARTS ( YEAR(f.FechaTimbrado), MONTH(f.FechaTimbrado), 01 )
							WHEN DAY(f.FechaTimbrado) > 20
								THEN DATEFROMPARTS ( YEAR(f.FechaTimbrado), MONTH(dateadd(MONTH,1,f.FechaTimbrado)), 01 )
						END AS MesPresentacion,
					   10004,
					   @IdUsuario,
					   GETDATE(),
					   pr.IdInstalacion,
					   pr.IdCatalogoCuentasSH,
					   1,
					   1,
					   pr.CostosAtribuiblesAdministracion,
					   SUBSTRING(CAST(pr.PCN AS NVARCHAR(50)), 1, 5),
					   pr.IdGastoRubro,
					   pr.IdCBSISH,
					   pr.IdAceptacionPedidoDetalle
				FROM Petrovendor.dbo.CO_Registro pr (NOLOCK)
				JOIN FI_Factura f 
					ON pr.IdFactura = f.IdFactura
				WHERE pr.IdRegistro = @IdRegistro;

				SELECT @IdRegistroAdinco = SCOPE_IDENTITY();

				SET @MontoRegistro = (SELECT TOP 1 MontoRegistro FROM Adinco.dbo.CO_Registro (NOLOCK) WHERE IdRegistro = @IdRegistroAdinco);

				INSERT INTO dbo.CO_RelacionRegistroAdinco (IdRegistroPetrovendor, IdRegistroAdinco)
				VALUES
				(   @IdRegistro,      -- IdRegistroPetrovendor - int  
					@IdRegistroAdinco -- IdRegistroAdinco - int  
				);

				INSERT INTO Adinco..CO_RegistroMarkup(
					GastoId,
					Porcentaje,
					MontoEquivalente,
					MontoGasto,
					Activo,
					CreadoPor,
					CreadoEn,
					ContratoId
				)
				VALUES
				(
					@IdRegistroAdinco,
					0,
					0,
					@MontoRegistro,
					1,
					ISNULL(@IdUsuarioADINCO,1),
					GETDATE(),
					10007--CONTRATO AMATITLAN;
				);
					
				

			END
			ELSE
			BEGIN -- SI NO ES AMATITLAN SIGUE SU CURSO NORMAL

				

				INSERT INTO Adinco.dbo.CO_Registro
				(
					IdPrograma,
					IdFactura,
					MontoRegistro,
					InicioEjecucion,
					FinEjecucion,
					Comentarios,
					MesPresentacion,
					IdEstado,
					IdUsuarioCreadoPor,
					FecMovto,
					IdInstalacion,
					IdCatalogoCuentasSH,
					Poliza,
					IsEditable,
					CostosAtribuiblesAdministracion,
					PCN,
					IdGastoRubro,
					IdCBSISH,
					IdAceptacionPedidoDetalle
				)
				SELECT pr.IdLineaPresupuestoMes,
					   @IdFacturaAdinco,
					   pr.MontoRegistro,
					   pr.InicioEjecucion,
					   pr.FinEjecucion,
					   pr.Comentarios,
					   pr.MesPresentacion,
					   10004,
					   @IdUsuario,
					   GETDATE(),
					   pr.IdInstalacion,
					   pr.IdCatalogoCuentasSH,
					   pr.Poliza,
					   1,
					   pr.CostosAtribuiblesAdministracion,
					   SUBSTRING(CAST(pr.PCN AS NVARCHAR(50)), 1, 5),
					   pr.IdGastoRubro,
					   pr.IdCBSISH,
					   pr.IdAceptacionPedidoDetalle
				FROM Petrovendor.dbo.CO_Registro pr (NOLOCK)
				WHERE pr.IdRegistro = @IdRegistro;
				SELECT @IdRegistroAdinco = SCOPE_IDENTITY();
				INSERT INTO dbo.CO_RelacionRegistroAdinco (IdRegistroPetrovendor, IdRegistroAdinco)
				VALUES
				(   @IdRegistro,      -- IdRegistroPetrovendor - int  
					@IdRegistroAdinco -- IdRegistroAdinco - int  
				);
			END
        END

        EXEC dbo.SP_WA_InserRegistroPaseAdinco @IdRegistro,                                          -- int  
                                               2,                                                    -- int  
                                               @IdRegistroAdinco,                                    -- int  
                                               @IdUsuario,                                           -- int  
                                               0,                                                    -- int  
                                               @IdContrato,                                          -- int  
                                               'PASE DE GASTO - ENVIO POR MM_SP_EnvioDeGastoAdinco', -- nvarchar(max)  
                                               '',                                                   -- nvarchar(50)  
                                               0;

        SET @IdRegistroAdinco = NULL;
        SET @Contador += 1;

    END;

END