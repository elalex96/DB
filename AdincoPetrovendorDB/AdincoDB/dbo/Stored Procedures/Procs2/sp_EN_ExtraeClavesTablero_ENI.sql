-- =============================================
-- Author: Daniel Ac
-- Create date: 20-11-2020
-- Description: Se agrego configuración estatica de reporte para ENI- TAB DE CN
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_ExtraeClavesTablero_ENI]
    @idContrato INT,
	@idUsuario INT,
    @IdRol INT,
	@IdTableroContrato INT
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @IsENI	BIT = 0,
		@IsEQUINOR	BIT	= 0

    --ESTE CONFIGURACIÓN ES ESTATICA PARA ENI --SE DEBE MOSTRAR EL TABLERO EN CN

	SELECT
		@IsENI	=	CASE	WHEN CA.NombreContratista	LIKE '%ENI%'	THEN 1 ELSE 0 END,
		@IsEQUINOR =	CASE	WHEN CA.NombreContratista	LIKE '%EQUINOR%'	THEN 1 ELSE 0 END
	FROM CO_Contrato	C
	JOIN CO_Contratista	CA
		ON C.IdContratista	=	CA.IdContratista
		AND C.IdContrato =	@idContrato

  --https://www.smps-adinco.com/#/site/Eni/views/EniLC_15962201107300/LocalContent 
	IF @IsENI = 1
	BEGIN
		
		SELECT Workbook='EniLC_15962201107300',
				Sheet='LocalContent',
				Tabs='no',
				Site='Eni',
				SiteT='/t/Eni',
				DNS='https://www.smps-adinco.com/trusted/',
				HeightPX=1110,
				Parametros='',
				Toolbar='no',
				UserTableau='admin' 

	END

	IF @IsEQUINOR = 1
	BEGIN
			
			SELECT Workbook='PMT',
				Sheet='PMT',
				Tabs='no',
				Site='Equinor',
				SiteT='/t/Equinor',
				DNS='https://www.smps-adinco.com/trusted/',
				HeightPX=800,
				Parametros='',
				Toolbar='si',
				UserTableau='AdminProcura' 
			
	END
	      
END;


