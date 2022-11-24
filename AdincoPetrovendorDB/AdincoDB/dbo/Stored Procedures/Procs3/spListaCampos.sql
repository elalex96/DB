-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	Lista los campos de una tabla
-- =============================================
CREATE PROCEDURE [dbo].[spListaCampos] 
	-- Add the parameters for the stored procedure here
	@tabla nvarchar (MAX), @lista int
AS
BEGIN

 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	IF (@lista =1)
		BEGIN
			select '@'+    COLUMN_NAME   , case  DATA_TYPE when 'nvarchar' then 'nvarchar(MAX)' when 'varchar' then 'nvarchar(MAX)' else  DATA_TYPE end+ ' ,',   '@'+    COLUMN_NAME + ','  , CASE DATA_TYPE
		    WHEN 'varchar' THEN 'string'  
			WHEN 'nvarchar' THEN 'string' 
			WHEN 'datetime' THEN 'DateTime'  
			WHEN 'money' THEN 'double'  
			WHEN 'decimal' THEN 'double'  
			WHEN 'bit' THEN 'bool'  
			WHEN 'float' THEN 'double' 
			WHEN 'date' THEN 'DateTime' 
			ELSE DATA_TYPE
		END + ' ' + COLUMN_NAME  +' { get; set; }' as propiedad
		, 'this.' + COLUMN_NAME + ' = ' + CASE DATA_TYPE
		    WHEN 'varchar' THEN 'string.Empty;'  
			WHEN 'nvarchar' THEN 'string.Empty;' 
			WHEN 'datetime' THEN 'DateTime.Now;'  
			WHEN 'money' THEN '0;'  
			WHEN 'decimal' THEN '0;'  
			WHEN 'bit' THEN 'false;'  
			WHEN 'float' THEN '0' 
			WHEN 'date' THEN 'DateTime.Now;' 
			WHEN 'int' then  '0;'
			ELSE DATA_TYPE
		END as Inicializar
			from INFORMATION_SCHEMA.COLUMNS
			where TABLE_NAME=@tabla 
		END
	ELSE
		BEGIN
		select    '// Agrega parametro para @'+COLUMN_NAME +   CHAR (13)  +  '_param = new DTO_ParametrosSP();'  + CHAR (13)  +'_param.NombreParametro = "@'+COLUMN_NAME + '";'  + CHAR(13) +'_param.Valor = "VALOR AQUI";' + CHAR(13) + 
		
		CASE DATA_TYPE
		    WHEN 'varchar' THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._String);'  
			WHEN 'nvarchar' THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._String);'  
			WHEN 'int' THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._Integer );'  
			WHEN 'datetime' THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._DateTime );'  
			WHEN 'money' THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._Decimal  );'  
			WHEN 'decimal' THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._Decimal  );'  
			WHEN 'bit' THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._Bool   );'  
			WHEN 'float' THEN '_param.TipoDeDato = Convert.ToInt32(ADINCO.UTL.TipoDato._Float   );'  
			ELSE DATA_TYPE
		END +  CHAR(13)+
		
		'_lista.Add(_param);'+ CHAR(13) 
			from INFORMATION_SCHEMA.COLUMNS
			where TABLE_NAME=@tabla
		END




    -- Insert statements for procedure here
	
END
