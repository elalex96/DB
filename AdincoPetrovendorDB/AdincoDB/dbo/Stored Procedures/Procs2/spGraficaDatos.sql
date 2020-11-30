-- =============================================
-- Author:		<Name,Name,Name>
-- Create date: <Create 21/DIC/2016,,>
-- Description:	<Procedimiento para dar formato a los valores deacuerdo al tipo de gráfica >
-- =============================================
CREATE PROCEDURE [dbo].[spGraficaDatos] 
	@ID_Grafica int, 
	@Fecha_Inicio datetime,
	@Fecha_Fin datetime,
	@Cadena varchar(max) output
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @TipoGraficaBD varchar(max) = (SELECT Tipo FROM DG_TipoGrafica AS TG, DG_Grafica AS G WHERE TG.Id_TipoGrafica=G.id_TipoGrafica AND G.Id_Grafica=@ID_Grafica)
	DECLARE @Periodo bit = (SELECT Periodo FROM  DG_Grafica AS G WHERE  G.Id_Grafica= @ID_Grafica)
	DECLARE @srtUpdateValor nvarchar(MAX)  =''
	DECLARE @SQLDatos nvarchar(MAX)   =''
	DECLARE @EjecutaDatos nvarchar(MAX)   =''
	DECLARE @DatosSerie nvarchar(MAX)   =''
	DECLARE @NumSeries int 
	DECLARE @i int 
	DECLARE @strColumna nvarchar(MAX)
	DECLARE @valor_i nvarchar(MAX)
	DECLARE @Nombre_Serie nvarchar(MAX)
	DECLARE @numSerie int 
	
	IF @TipoGraficaBD = 'line' OR @TipoGraficaBD = 'bar' OR @TipoGraficaBD = 'column' OR @TipoGraficaBD = 'area' OR @TipoGraficaBD = 'column3D' OR @TipoGraficaBD = 'column_SP' 
	BEGIN 		 
		--- Se cuenta le numero de series que contiene la gráfica
		SET @NumSeries  = (SELECT COUNT(DG_Series.IdSerie)
									FROM DG_Series
									WHERE DG_SERIES.IdGrafica= @ID_Grafica)
		set @i  = 1
		
		CREATE TABLE #FECHAS (Fecha DATE)
		CREATE TABLE #SERIES (NumID int identity(1,1), IdSerie int)
		CREATE TABLE #DATOS (VALORES NVARCHAR(MAX))

		--Se insertan los Id´s de las series de la gráfica a la tabla #Series
		INSERT INTO #SERIES
		SELECT idSerie 
		FROM DG_SERIES AS S WHERE S.IdGrafica=@ID_Grafica
		ORDER BY idSerie ASC
		
		-- Se hace un ciclo para agregar el numero de columnas ValorX según el numero de series
		WHILE @i <= @NumSeries
			BEGIN
				SET @valor_i    = 'Valor'+CAST(@i AS nvarchar(max))
				SET @strColumna =  N'ALTER TABLE  #FECHAS ADD '+@valor_i+N' float null'
				EXECUTE sp_executesql  @strColumna 
				SET @i=@i+1;
			END
		
		-- Se selecciona el periódo de inicio y fin de los datos de las series
		IF @Periodo = 1
			BEGIN
				INSERT INTO  #FECHAS("FECHA")
				SELECT DISTINCT FECHA  
				FROM DG_Valores WHERE DG_Valores.IdSerie IN (SELECT DG_Series.IdSerie
				FROM DG_Series
				WHERE DG_SERIES.IdGrafica= @ID_Grafica
				AND FECHA BETWEEN @Fecha_Inicio AND @Fecha_Fin)
				ORDER BY Fecha ASC
			END 
		ELSE  
			BEGIN
				INSERT INTO  #FECHAS("FECHA")
				SELECT DISTINCT FECHA  
				FROM DG_Valores WHERE DG_Valores.IdSerie IN (SELECT DG_Series.IdSerie
				FROM DG_Series
				WHERE DG_SERIES.IdGrafica= @ID_Grafica)
				ORDER BY FECHA ASC
			END
	 
		SET @i  = 1
		SET @valor_i  = ''
		
		-- Se recorren la tabla #Fechas para armar el formato data para la gráfica 
		 WHILE @i <= @NumSeries
			BEGIN

				SET @valor_i    = 'Valor'+CAST(@i AS nvarchar(max))
				SET @srtUpdateValor =  ' UPDATE #FECHAS SET  '+@valor_i+' = V.Valor FROM #FECHAS FULL OUTER JOIN DG_Valores AS V ON V.Fecha=#FECHAS.Fecha WHERE IdSerie= (SELECT IdSerie FROM #Series WHERE #Series.NumID='''+CAST(@i AS nvarchar(max))+''')'
				SET @srtUpdateValor = @srtUpdateValor + ' UPDATE #FECHAS SET '+@valor_i+'=0 WHERE ISNULL('+@valor_i+',0)=0 '
				BEGIN 
				EXECUTE sp_executesql  @srtUpdateValor
				END
				SET @srtUpdateValor = ''
				SET  @EjecutaDatos  = 
				'INSERT INTO #DATOS(VALORES) VALUES(  ''{ name: '''''' + (SELECT S.Nombre FROM DG_SERIES AS S WHERE S.IdSerie=(SELECT IdSerie FROM #Series WHERE #Series.NumID='''+CAST(@i AS nvarchar(max))+''') ) +'''''', data: [''
					+ (SELECT STUFF((
						SELECT '', '' + CAST(V.'+@valor_i+' AS VARCHAR(MAX))
						FROM #FECHAS AS V 
						FOR XML PATH('''')
					), 1, 1, '''') ) 
					+'']}'')'
				BEGIN		
				EXECUTE sp_executesql  @EjecutaDatos
				END		
				SET @i=@i+1;

			END 

		SET  @Cadena =(SELECT stuff((
		SELECT ', ' + Valores
		FROM #Datos 
			 
		FOR XML PATH('')
		), 1, 1, '') Valores )
		
  
	END 

	ELSE IF @TipoGraficaBD = 'pie'  
 	BEGIN 
	
		SET @NumSeries  = (SELECT COUNT(DG_Series.IdSerie)
                                    FROM DG_Series
                                    WHERE DG_SERIES.IdGrafica= @ID_Grafica)
        SET @i  = 1
        CREATE TABLE #FECHAS_P (Fecha DATE)
        CREATE TABLE #SERIES_P (NumID int identity(1,1), IdSerie int)
        CREATE TABLE #DATOS_P (VALORES NVARCHAR(MAX))

        INSERT INTO #SERIES_P
        SELECT idSerie 
        FROM DG_SERIES AS S WHERE S.IdGrafica=@ID_Grafica
        ORDER BY idSerie ASC

        WHILE @i <= @NumSeries
            BEGIN
                SET @valor_i    = 'Valor'+CAST(@i AS nvarchar(max))
                SET @strColumna =  N'ALTER TABLE  #FECHAS_P ADD '+@valor_i+N' float null'
                EXECUTE sp_executesql  @strColumna 
                SET @i=@i+1;
            END

        
        IF @Periodo = 1
            BEGIN
                INSERT INTO  #FECHAS("FECHA")
                SELECT DISTINCT FECHA  
                FROM DG_Valores WHERE DG_Valores.IdSerie IN (SELECT DG_Series.IdSerie
                FROM DG_Series
                WHERE DG_SERIES.IdGrafica= @ID_Grafica
                AND FECHA BETWEEN @Fecha_Inicio AND @Fecha_Fin)
                ORDER BY Fecha ASC
            END 
        ELSE  
            BEGIN 
                INSERT INTO  #FECHAS_P("FECHA")
                SELECT DISTINCT FECHA  
                FROM DG_Valores WHERE DG_Valores.IdSerie IN (SELECT DG_Series.IdSerie
                FROM DG_Series
                WHERE DG_SERIES.IdGrafica= @ID_Grafica)
                ORDER BY Fecha ASC
            END 

        SET @i  = 1
        SET @valor_i  = ''
        
     	
    SET @i  = 1
	SET @valor_i  = ''
         WHILE @i <= @NumSeries
            BEGIN

                SET @valor_i    = 'Valor'+CAST(@i AS nvarchar(max))
                SET @srtUpdateValor =  ' UPDATE #FECHAS_P SET  '+@valor_i+' = V.Valor FROM #FECHAS_P FULL OUTER JOIN DG_Valores AS V ON V.Fecha=#FECHAS_P.Fecha WHERE IdSerie= (SELECT IdSerie FROM #Series_P WHERE #Series_P.NumID='''+CAST(@i AS nvarchar(max))+''')'
                SET @srtUpdateValor = @srtUpdateValor + ' UPDATE #FECHAS_P SET '+@valor_i+'=0 WHERE ISNULL('+@valor_i+',0)=0 '
                BEGIN 
                    EXECUTE sp_executesql  @srtUpdateValor
                END
                SET @srtUpdateValor = ''
                SET  @EjecutaDatos  = 
                'INSERT INTO #DATOS_P(VALORES) VALUES(  (SELECT ''[ '''''' +  S.Nombre +''''''''+'','' FROM DG_SERIES AS S WHERE S.IdSerie=(SELECT IdSerie FROM #Series_P WHERE #Series_P.NumID='''+CAST(@i AS nvarchar(max))+N''') ) 
                    + (SELECT STUFF((
                        SELECT '', '' + CAST(V.'+@valor_i+' AS VARCHAR(MAX))
                        FROM #FECHAS_P AS V 
                        FOR XML PATH('''')
                    ), 1, 1, '''') ) 
                    +'']'''+')'

                BEGIN       
                   EXECUTE sp_executesql  @EjecutaDatos
                END     
                SET @i=@i+1;

            END 

        SET  @Cadena =(SELECT stuff((
        SELECT ', ' + Valores
        FROM #Datos_P 
             
        FOR XML PATH('')
        ), 1, 1, '') Valores )

	END 

	ELSE IF  @TipoGraficaBD = 'column3D_SG'
	BEGIN
	
		SET @NumSeries  = (SELECT COUNT(DG_Series.IdSerie)
									FROM DG_Series
									WHERE DG_SERIES.IdGrafica= @ID_Grafica)
		SET @i  = 1
		CREATE TABLE #FECHAS_SG (Fecha DATE)
		CREATE TABLE #SERIES_SG (NumID int identity(1,1), IdSerie int)
		CREATE TABLE #DATOS_SG (VALORES NVARCHAR(MAX))

		INSERT INTO #SERIES_SG
		SELECT idSerie 
		FROM DG_SERIES AS S WHERE S.IdGrafica=@ID_Grafica
		ORDER BY idSerie ASC

		WHILE @i <= @NumSeries
			BEGIN
				SET @valor_i    = 'Valor'+CAST(@i AS nvarchar(max))
				SET @strColumna =  N'ALTER TABLE  #FECHAS_SG ADD '+@valor_i+N' float null'
				EXECUTE sp_executesql  @strColumna 
				SET @i=@i+1;
			END

		
		IF @Periodo = 1
			BEGIN
				INSERT INTO  #FECHAS("FECHA")
				SELECT DISTINCT FECHA  
				FROM DG_Valores WHERE DG_Valores.IdSerie IN (SELECT DG_Series.IdSerie
				FROM DG_Series
				WHERE DG_SERIES.IdGrafica= @ID_Grafica
				AND FECHA BETWEEN @Fecha_Inicio AND @Fecha_Fin)
				ORDER BY Fecha ASC
			END 
		ELSE  
			BEGIN 
				INSERT INTO  #FECHAS_SG("FECHA")
				SELECT DISTINCT FECHA  
				FROM DG_Valores WHERE DG_Valores.IdSerie IN (SELECT DG_Series.IdSerie
				FROM DG_Series
				WHERE DG_SERIES.IdGrafica= @ID_Grafica)
				ORDER BY Fecha ASC
			END 

		SET @i  = 1
		SET @valor_i  = ''
		
		 WHILE @i <= @NumSeries
			BEGIN

				SET @valor_i    = 'Valor'+CAST(@i AS nvarchar(max))
				SET @srtUpdateValor =  ' UPDATE #FECHAS_SG SET  '+@valor_i+' = V.Valor FROM #FECHAS_SG FULL OUTER JOIN DG_Valores AS V ON V.Fecha=#FECHAS_SG.Fecha WHERE IdSerie= (SELECT IdSerie FROM #Series_SG WHERE #Series_SG.NumID='''+CAST(@i AS nvarchar(max))+''')'
				SET @srtUpdateValor = @srtUpdateValor + ' UPDATE #FECHAS_SG SET '+@valor_i+'=0 WHERE ISNULL('+@valor_i+',0)=0 '
				BEGIN 
					EXECUTE sp_executesql  @srtUpdateValor
				END
				SET @srtUpdateValor = ''
				SET  @EjecutaDatos  = 
				'INSERT INTO #DATOS_SG(VALORES) VALUES(  (SELECT ''{ name: '''''' +  S.Nombre +N'''''', stack:''''''+S.Stack+N'''''',color:{linearGradient: { x1: 0, x2: 0, y1: 0, y2: 1 },stops: [ [0, ''''''+s.Color_Stock_0+N''''''],[1, ''''''+s.Color_Stock_1+N'''''']]'' FROM DG_SERIES AS S WHERE S.IdSerie=(SELECT IdSerie FROM #Series_SG WHERE #Series_SG.NumID='''+CAST(@i AS nvarchar(max))+N''') ) +N''}, data: [''
					+ (SELECT STUFF((
						SELECT '', '' + CAST(V.'+@valor_i+' AS VARCHAR(MAX))
						FROM #FECHAS_SG AS V 
						FOR XML PATH('''')
					), 1, 1, '''') ) 
					+'']}'')'

				BEGIN		
					EXECUTE sp_executesql  @EjecutaDatos
				END		
				SET @i=@i+1;

			END 

		SET  @Cadena =(SELECT stuff((
		SELECT ', ' + Valores
		FROM #Datos_SG 
			 
		FOR XML PATH('')
		), 1, 1, '') Valores )

	END

	ELSE IF  @TipoGraficaBD = 'colum_line_pie'
	BEGIN


        SET @NumSeries  = (SELECT COUNT(DG_Series.IdSerie)
                                    FROM DG_Series
                                    WHERE DG_SERIES.IdGrafica= @ID_Grafica)
        set @i  = 1
        
        CREATE TABLE #FECHAS_CLP (Fecha DATE)
        CREATE TABLE #SERIES_CLP (NumID int identity(1,1), IdSerie int)
        CREATE TABLE #DATOS_CLP (VALORES NVARCHAR(MAX))

        INSERT INTO #SERIES_CLP
        SELECT idSerie 
        FROM DG_SERIES AS S WHERE S.IdGrafica=@ID_Grafica
        ORDER BY idSerie ASC
 
        WHILE @i <= @NumSeries
            BEGIN
                SET @valor_i    = 'Valor'+CAST(@i AS nvarchar(max))
                SET @strColumna =  N'ALTER TABLE  #FECHAS_CLP ADD '+@valor_i+N' float null'
                EXECUTE sp_executesql  @strColumna 
                SET @i=@i+1;
            END
		
		IF @Periodo = 1
			BEGIN
				INSERT INTO  #FECHAS("FECHA")
				SELECT DISTINCT FECHA  
				FROM DG_Valores WHERE DG_Valores.IdSerie IN (SELECT DG_Series.IdSerie
				FROM DG_Series
				WHERE DG_SERIES.IdGrafica= @ID_Grafica
				AND FECHA BETWEEN @Fecha_Inicio AND @Fecha_Fin)
				ORDER BY Fecha ASC
			END 
		ELSE 
			BEGIN
				INSERT INTO  #FECHAS_CLP("FECHA")
				SELECT DISTINCT FECHA  
				FROM DG_Valores WHERE DG_Valores.IdSerie IN (SELECT DG_Series.IdSerie
				FROM DG_Series
				WHERE DG_SERIES.IdGrafica= @ID_Grafica)
				ORDER BY Fecha ASC
			END
    
        SET @i  = 1
        SET @valor_i  = ''
		SET @NumSeries  = (SELECT COUNT(DG_Series.IdSerie)
                                    FROM DG_Series
                                    WHERE DG_SERIES.IdGrafica= @ID_Grafica)
        

         WHILE @i <= @NumSeries
            BEGIN

                SET @valor_i    = 'Valor'+CAST(@i AS nvarchar(max))
                SET @srtUpdateValor =  ' UPDATE #FECHAS_CLP SET  '+@valor_i+' = V.Valor FROM #FECHAS_CLP FULL OUTER JOIN DG_Valores AS V ON V.Fecha=#FECHAS_CLP.Fecha WHERE IdSerie= (SELECT IdSerie FROM #Series_CLP WHERE #Series_CLP.NumID='''+CAST(@i AS nvarchar(max))+''')'
                SET @srtUpdateValor = @srtUpdateValor + ' UPDATE #FECHAS_CLP SET '+@valor_i+'=0 WHERE ISNULL('+@valor_i+',0)=0 '
                BEGIN 
                EXECUTE sp_executesql  @srtUpdateValor
                END
                SET @srtUpdateValor = ''
                SET  @EjecutaDatos  = 
                'INSERT INTO #DATOS_CLP(VALORES) VALUES(  (SELECT ''{type:'''''' +  S.Type_Serie +N'''''', name: '''''' +  S.Nombre +N'''''' , color:''''''+S.Color_Serie FROM DG_SERIES AS S WHERE S.IdSerie=(SELECT IdSerie FROM #Series_CLP WHERE #Series_CLP.NumID='''+CAST(@i AS nvarchar(max))+N''') ) +N'''''', data: [''
					+ (SELECT STUFF((
						SELECT '', '' + CAST(V.'+@valor_i+' AS VARCHAR(MAX))
						FROM #FECHAS_CLP AS V 
						FOR XML PATH('''')
					), 1, 1, '''') ) 
					+'']}'')'
				BEGIN       
                  EXECUTE sp_executesql  @EjecutaDatos
                END     
                SET @i=@i+1;

            END 

		
        SET  @Cadena =(SELECT stuff((
        SELECT ', ' + Valores
        FROM #Datos_CLP 
             
        FOR XML PATH('')
        ), 1, 1, '') Valores )

			
	END 
END




