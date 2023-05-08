-- =============================================
-- Author:		Reyna Olvera
-- Create date: 05-01-2018
-- Description:	Calcula Indicadores si sus insumos ya han sdo capturados
-- =============================================
CREATE PROCEDURE [dbo].[IN_CalculaIndicador]
	-- Add the parameters for the stored procedure here
	@indicador int, 
	@idContrato int,
	@idUsuario int,
	@periodo date
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  

Declare @mesNombreAnterior varchar(50),
 @añoAnterior int,
 @AñoCurso int,
 @mesNombre varchar(50),
 @idIndicadorContrato int,
 @formulaPrinc varchar (2000),
 @insumo varchar(100), 
 @in decimal(28,16), 
 @CanInsumo int,
 @Cont int,
 @id int,
 @idInsumo int,
 @idControlInsumo int,
 @totalCant  decimal (24,8),
 @idInsumoIndicador int;


		--Verifica en que mes se esta ejecutando el sp
		set 
		language 'spanish'
		SELECT @mesNombre = DATENAME(month, GETDATE()) 

		--Checa mes anterior de que se ejecuto el sp
		set 
		language 'spanish'
		SELECT @mesNombreAnterior = DATENAME (Month, DATEADD(M,-1,GETDATE() ))

		--Checa los Años
		SELECT @AñoCurso =year(GetDate());
		SELECT @añoAnterior = DATENAME (Year, DATEADD(M,-1,GETDATE() ));
		----------------------------------------------------------------------------------------------------
		--Creacion de tablas para guardar datos
				IF OBJECT_ID('tempdb..#tablaTemporaInsumos') IS NOT NULL
				DROP TABLE #tablaTemporaInsumos
				CREATE TABLE #tablaTemporaInsumos( id INT primary key identity(1,1) , idInsumo int);

				IF OBJECT_ID('tempdb..#tablaTemporaInsumoIndicador') IS NOT NULL
				DROP TABLE #tablaTemporaInsumoIndicador
				CREATE TABLE #tablaTemporaInsumoIndicador( id INT primary key identity(1,1) , idInsumoIndicador int);

				IF OBJECT_ID('tempdb..#tablaTemporaNomInsumos') IS NOT NULL
				DROP TABLE #tablaTemporaNomInsumos
				CREATE TABLE #tablaTemporaNomInsumos( id INT primary key identity(1,1) , ValorFormula varchar(100));

		
				IF OBJECT_ID('tempdb..#tablaTemporaControlInsumos') IS NOT NULL
				DROP TABLE #tablaTemporaControlInsumos
				CREATE TABLE #tablaTemporaControlInsumos( id INT primary key identity(1,1) , idControlInsumo int);

		
			    IF OBJECT_ID('tempdb..#tablaTemporalValCantidad') IS NOT NULL
				DROP TABLE #tablaTemporalValCantidad
			    CREATE TABLE #tablaTemporalValCantidad( id INT primary key identity(1,1) , valorCantidad decimal(24,8));
				
				IF OBJECT_ID('tempdb..#totales') IS NOT NULL
				DROP TABLE #totales
			    CREATE TABLE #totales( id INT primary key identity(1,1) , total decimal(28,16));


		--**************************************
--
				Select @idIndicadorContrato= idIndicadorContrato from in_indicadorPorContrato where idIndicador =@indicador and IdContrato=@idContrato;
				Select @totalCant= Total from in_totalIndicadorMes where idIndicadorContrato=@idIndicadorContrato And periodoMes=@mesNombre And año=@AñoCurso 
		--Verifica que en el momento de ejecutar el sp el indicador tenga un total 
		if ( @totalCant is null)
					Begin
					--selecciona la formula que maneja tal indicador
						Select @formulaPrinc= formula from IN_Indicadores where idIndicador=@indicador;
						--da la cantidad de insumos del indicador
						Select @CanInsumo= Count(idInsumo) from IN_InsumoIndicador where  idIndicador=@indicador
						--guarda los insumos
						INSERT INTO #tablaTemporaInsumos(idInsumo)
						Select idInsumo from IN_InsumoIndicador where idIndicador=@indicador
						
Set @cont=1;

							while(@cont<=@CanInsumo)
								begin
								--toma los insumos y guarda las variables quer tiene como valor la formula
									Select @idInsumo= idInsumo from #tablaTemporaInsumos where id=@cont

									INSERT INTO #tablaTemporaNomInsumos(ValorFormula)
									select ValorFormula 
									from  in_insumos
									where idInsumo=@idInsumo;
		
									select @idInsumoIndicador= idInsumoIndicador 
									from IN_insumoIndicador
									where idInsumo= @idInsumo and idIndicador=@indicador;
							--para saber si tal insumo ya ha sido capturado en el mes que se ejecuta el sp
									INSERT INTO #tablaTemporaControlInsumos(idControlInsumo)
									select idControlInsumo
									from in_ControlInsumo
									where idInsumoIndicador=@idInsumoIndicador

									Select @idControlInsumo= idControlInsumo 
									from #tablaTemporaControlInsumos
									where id =@cont

				if( ( Select valorCantidad from IN_InsumoPorMes where idControlInsumo=@idControlInsumo and periodoMes Like  ''+@mesNombre+'%' And año=@AñoCurso ) is not null)
		
						begin
						--si ya fue capturado el dato remplaza la variable e inserta la cantidad del insumo en la formula
							INSERT INTO #tablaTemporalValCantidad(valorCantidad)
							Select valorCantidad  as insumoCant from IN_InsumoPorMes
							where idControlInsumo=@idControlInsumo and periodoMes Like  ''+@mesNombre+'%' And año=@AñoCurso;	
						end
		
							Select @in= valorCantidad from #tablaTemporalValCantidad where id =@cont;	
							Select @insumo= ValorFormula from #tablaTemporaNomInsumos where id =@cont;	
							Select @formulaPrinc =  replace(@formulaPrinc, @insumo, @in);

			
----------------------------------
SET @cont = @cont+ 1;

								End
								--si no ha sido capturada selecciona los demas datos de ese indicador de ese Año

				if(@mesNombreAnterior='Diciembre')
					begin
							Select total, Nombre,Titulo, periodoMes,Año,periodo
							from in_totalIndicadorMes totalInd 
							inner join in_IndicadorPorContrato IndicaCo on totalInd.idIndicadorContrato= IndicaCo.idIndicadorContrato
							inner join IN_Indicadores as indica on IndicaCo.idIndicador= indica.idIndicador
							 where IndicaCo.idIndicadorContrato=@idIndicadorContrato And  totalInd.Año=@AñoAnterior; 
					end

				else
					begin

						Select total, Nombre,Titulo,PeriodoMes,Año,periodo
						from in_totalIndicadorMes totalInd 
						inner join in_IndicadorPorContrato IndicaCo on totalInd.idIndicadorContrato= IndicaCo.idIndicadorContrato
						inner join IN_Indicadores as indica on IndicaCo.idIndicador= indica.idIndicador
							where IndicaCo.idIndicadorContrato=@idIndicadorContrato And  totalInd.Año=@AñoCurso ;

					end


				if((Select valorCantidad from IN_InsumoPorMes where idControlInsumo=@idControlInsumo and periodoMes Like  ''+@mesNombre+'%' And Año=@AñoCurso) is Not Null)
					begin
					--ejecuta la formula, da resultado y la inserta en una tabla de totales para despues seleccionar
					--todos los resultados de ese Año y de ese indicador para ese contrato
		insert into #totales 
		exec  ('select '+ @formulaPrinc+' ') ;
		
		select  @totalCant =total from #totales

		insert into IN_TotalIndicadorMes (total,fechaCapturado,PeriodoMes,idIndicadorContrato,Año,periodo) 
		values(@totalCant,GetDate(),@mesNombre,@idIndicadorContrato,@AñoCurso,@periodo);

					Select Total, Nombre,Titulo, periodoMes,Año,periodo
					from in_totalIndicadorMes totalInd 
					inner join in_IndicadorPorContrato IndicaCo on totalInd.idIndicadorContrato= IndicaCo.idIndicadorContrato
					inner join IN_Indicadores as indica on IndicaCo.idIndicador= indica.idIndicador
					where totalInd.idIndicadorContrato=@idIndicadorContrato And totalInd.periodoMes=@mesNombre

		end
	
END



	else
			begin 

					Select Total, Nombre,Titulo,periodoMes,Año,periodo
					from in_totalIndicadorMes totalInd 
					inner join in_IndicadorPorContrato IndicaCo on totalInd.idIndicadorContrato= IndicaCo.idIndicadorContrato
					inner join IN_Indicadores as indica on IndicaCo.idIndicador= indica.idIndicador
					where totalInd.idIndicadorContrato=@idIndicadorContrato  And  totalInd.Año=@AñoCurso;

			end




END