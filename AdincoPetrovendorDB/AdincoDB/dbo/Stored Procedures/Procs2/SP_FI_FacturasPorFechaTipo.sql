CREATE PROCEDURE [dbo].[SP_FI_FacturasPorFechaTipo] 
@Tipo VARCHAR(MAX),
@Inicio DATE,
@Fin DATE,
@IdUsuario      INT, 
@IdContrato INT 
AS
BEGIN
	SET NOCOUNT ON;
	IF(@Tipo = 'Recibidas')
		BEGIN 
			SELECT DISTINCT 
				F.IdFactura, 
				F.IdContrato,
				F.UUID AS NombreArchivo                          
			FROM 
				dbo.FI_Factura AS F WITH(NOLOCK)  
					LEFT JOIN dbo.FI_FacturaContrato FC WITH(NOLOCK) ON 
						F.IdFactura = FC.IdFactura  
					JOIN dbo.PV_Subcontratista AS S WITH(NOLOCK) ON 
						F.IdSubcontratista = S.IdSubcontratista  
					JOIN dbo.CO_Contrato C WITH(NOLOCK) ON 
						F.IdContrato = C.IdContrato AND 
						(F.IdContrato = @IdContrato  OR FC.IdContrato = @IdContrato)  
					JOIN dbo.CO_Contratista CC WITH(NOLOCK) ON 
						C.IdContratista = CC.IdContratista AND 
						CC.RFC <> F.Emisor  
			WHERE F.Fecha BETWEEN @Inicio AND @Fin AND
				  F.TipoComprobante IS NOT NULL AND
				  F.UUID IS NOT NULL
			ORDER BY F.IdFactura DESC;             
		END;
	IF(@Tipo = 'Emitidas')
		BEGIN 			
			SELECT DISTINCT
				F.IdFactura, 
				F.IdContrato,
				F.UUID AS NombreArchivo
			FROM 
				dbo.FI_Factura AS F(NOLOCK)
					JOIN dbo.CO_Contrato C(NOLOCK) ON
						F.IdContrato = C.IdContrato
					JOIN dbo.CO_Contratista CC(NOLOCK) ON 
						C.IdContratista = CC.IdContratista AND 
						F.Emisor = CC.RFC                      
			WHERE F.IdContrato = @IdContrato AND 
				  F.Fecha BETWEEN @Inicio AND @Fin AND
				  F.TipoComprobante IS NOT NULL AND
				  F.UUID IS NOT NULL
			ORDER BY F.IdFactura DESC;             
		END;
END;