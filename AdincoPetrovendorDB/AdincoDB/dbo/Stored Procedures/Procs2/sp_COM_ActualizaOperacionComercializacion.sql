CREATE PROCEDURE [dbo].[sp_COM_ActualizaOperacionComercializacion]
@IdOperacionComercializacion   INT, 
@IdContrato                    INT, 
@MesReporte                    DATE, 
@FechaTransaccion              DATE, 
@IdTipoHidrocarburo            INT, 
@VolumenVendido                FLOAT, 
@PrecioVentaUnitario           MONEY, 
@CostoUnitarioComercializacion MONEY, 
@PrecioPuntoMedicion           MONEY, 
@IdFactura                     INT, 
@NumeroFolioPedimento          NVARCHAR(MAX), 
@EPT                           BIT, 
@OperacionBajoReglasMercado    BIT, 
@ClasificacionDocumentoSoporte INT, 
@IdUsuario                     INT, 
@PenaEconomica                 FLOAT         = 0
AS
     BEGIN
         --
         SET NOCOUNT ON;
         DECLARE @InsertedRecord INT;

		 INSERT INTO [dbo].[AP_BitacoraErrores](Mensaje,StackTrace,IdUsuario,IdContrato,FechaRegistro)
		 SELECT 
			CONCAT('Modificación de comercialización: ',  LTRIM(@IdOperacionComercializacion)),
		 CONCAT(
		 CASE 
			WHEN [MesReporte] != @MesReporte
			THEN 
			CONCAT(' [MesReporte Antes: ',LTRIM([MesReporte]),' - ','Despues: ',(@MesReporte),'] ')
		 END,
		  CASE 
			WHEN [FechaTransaccion] != @FechaTransaccion
			THEN 
			CONCAT(' [FechaTransaccion Antes: ',LTRIM([FechaTransaccion]),' - ','Despues: ',LTRIM(@FechaTransaccion),'] ')
		   END,
		   CASE 
			WHEN [IdTipoHidrocarburo] != @IdTipoHidrocarburo
			THEN 
			CONCAT('[IdTipoHidrocarburo Antes: ',LTRIM([IdTipoHidrocarburo]),' - ','Despues: ',LTRIM(@IdTipoHidrocarburo),'] ')
		   END,
		    CASE 
				WHEN [VolumenVendido] != @VolumenVendido
				THEN 
				CONCAT('[VolumenVendido Antes: ',LTRIM([VolumenVendido]),' - ','Despues: ',LTRIM(@VolumenVendido),'] ')
		    END,
			CASE 
				WHEN [PrecioVentaUnitario] != @PrecioPuntoMedicion
				THEN 
				CONCAT('[PrecioVentaUnitario Antes: ',LTRIM([PrecioVentaUnitario]),' - ','Despues: ',LTRIM(@PrecioVentaUnitario),'] ')
		    END,
			CASE 
				WHEN [CostoUnitarioComercializacion] != @CostoUnitarioComercializacion
				THEN 
				CONCAT('[CostoUnitarioComercializacion Antes: ',LTRIM([CostoUnitarioComercializacion]),' - ','Despues: ',LTRIM(@CostoUnitarioComercializacion),'] ')
		    END,
			CASE 
				WHEN [PrecioPuntoMedicion] != @PrecioPuntoMedicion
				THEN 
				CONCAT('[PrecioPuntoMedicion Antes: ',LTRIM([PrecioPuntoMedicion]),' - ','Despues: ',LTRIM(@PrecioPuntoMedicion),'] ')
		    END,
			CASE 
				WHEN [IdFactura] != @IdFactura
				THEN 
				CONCAT('[IdFactura Antes: ',LTRIM([IdFactura]),' - ','Despues: ',LTRIM(@IdFactura),'] ')
		    END,
			CASE 
				WHEN [NumeroFolioPedimento] != @NumeroFolioPedimento
				THEN 
				CONCAT('[NumeroFolioPedimento Antes: ',LTRIM([NumeroFolioPedimento]),' - ','Despues: ',LTRIM(@NumeroFolioPedimento),'] ')
		    END,
			CASE 
				WHEN [EPT] != @EPT
				THEN 
				CONCAT('[EPT Antes: ',LTRIM([EPT]),' - ','Despues: ',LTRIM(@EPT),'] ')
		    END,
			CASE 
				WHEN [OperacionBajoReglasMercado] != @OperacionBajoReglasMercado
				THEN 
				CONCAT('[OperacionBajoReglasMercado Antes: ',LTRIM([OperacionBajoReglasMercado]),' - ','Despues: ',LTRIM(@OperacionBajoReglasMercado),'] ')
		    END,
			CASE 
				WHEN [ClasificacionDocumentoSoporte] != @ClasificacionDocumentoSoporte
				THEN 
				CONCAT('[ClasificacionDocumentoSoporte Antes: ',LTRIM([ClasificacionDocumentoSoporte]),' - ','Despues: ',LTRIM(@ClasificacionDocumentoSoporte),'] ')
		    END,
			CASE 
				WHEN [PenaEconomica] != @PenaEconomica
				THEN 
				CONCAT('[PenaEconomica Antes: ',LTRIM([PenaEconomica]),' - ','Despues: ',LTRIM(@PenaEconomica),'] ')
		    END ),
		 @IdUsuario, @IdContrato, GETDATE()
		 FROM	[COM_OperacionComercializacion]
		 WHERE IdOperacionComercializacion = @IdOperacionComercializacion;

         UPDATE [COM_OperacionComercializacion]
           SET 
               [MesReporte] = @MesReporte, 
               [FechaTransaccion] = @FechaTransaccion, 
               [IdTipoHidrocarburo] = @IdTipoHidrocarburo, 
               [VolumenVendido] = @VolumenVendido, 
               [PrecioVentaUnitario] = @PrecioVentaUnitario, 
               [CostoUnitarioComercializacion] = @CostoUnitarioComercializacion, 
               [PrecioPuntoMedicion] = @PrecioPuntoMedicion, 
               [IdFactura] = @IdFactura, 
               [NumeroFolioPedimento] = @NumeroFolioPedimento, 
               [EPT] = @EPT, 
               [OperacionBajoReglasMercado] = @OperacionBajoReglasMercado, 
               [ClasificacionDocumentoSoporte] = @ClasificacionDocumentoSoporte, 
               [PenaEconomica] = @PenaEconomica,
			   [ModificadoPor] = @IdUsuario, 
               [ModificadoEl] = GETDATE()
         WHERE IdOperacionComercializacion = @IdOperacionComercializacion;

     END;
