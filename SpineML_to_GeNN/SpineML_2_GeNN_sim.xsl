<?xml version="1.0" encoding="ISO-8859-1"?><xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:SMLLOWNL="http://www.shef.ac.uk/SpineMLLowLevelNetworkLayer" 
xmlns:SMLNL="http://www.shef.ac.uk/SpineMLNetworkLayer" 
xmlns:SMLCL="http://www.shef.ac.uk/SpineMLComponentLayer" 
xmlns:SMLEX="http://www.shef.ac.uk/SpineMLExperimentLayer" 
xmlns:fn="http://www.w3.org/2005/xpath-functions">
<xsl:output method="text" version="1.0" encoding="UTF-8" indent="yes"/>
<xsl:template match="/">

<xsl:variable name="experiment_file" select="/"/>

<!-- since we start in the experiment file we need to use for-each to get to the model file -->
<xsl:variable name="model_xml" select="//SMLEX:Model/@network_layer_url"/>
<xsl:for-each select="document($model_xml)"> <!-- GET INTO NETWORK FILE -->


//--------------------------------------------------------------------------
/*! This function is the entry point for running the simulation in GeNN
	Autogenerated using XSLT script - Alex Cope 2013

*/
//--------------------------------------------------------------------------

#include &lt;cuda_runtime.h&gt;
//#include &lt;helper_cuda.h&gt;

#include "../../lib/include/hr_time.h"
CStopWatch timer;
#include "../../lib/include/hr_time.cpp"

#include "../../lib/include/numlib/simpleBit.h"

#include "model.cc"
#include "<xsl:value-of select="translate(/SMLLOWNL:SpineML/@name,' ','_')"/>_CODE/runner.cc"

#define CPU 0
#define GPU 1

// GLOBALS
float t = 0.0f;

#ifndef __RNG_FUNCS_
#define __RNG_FUNCS_

#include "rng.h"

// Some data for the random number generator.
RngData rngData;

float uniformRand(float min, float max) {
	return _randomUniform(&amp;rngData)*(max-min)+min;
}
float normalRand(float mean, float std) {
	return _randomNormal(&amp;rngData)*std-mean;
}
float poissonRand() {
	return _randomPoisson(&amp;rngData);
}

#endif

struct conn {
	unsigned int src;
	unsigned int dst;
};
	
struct conn_with_delay {
	unsigned int src;
	unsigned int dst;
	float delay;
};

int main(int argc, char *argv[])
{

	zigset(&amp;rngData,123);

// safety first:
if (sizeof(conn) != 8) {
	cerr &lt;&lt; "Error: Expected a structure of 2 unsigned ints to be 8 bytes - this is not the case\n\n";
	exit(-1);
}
if (sizeof(conn_with_delay) != 12) {
	cerr &lt;&lt; "Error: Expected a structure of 2 unsigned ints and a float to be 12 bytes - this is not the case\n\n";
	exit(-1);
}
// for now....
	int which = GPU;

// DEFINES
  NNmodel model;

// SOME SETUP
  modelDefinition(model);
  allocateMem();
  initialize();

  //-----------------------------------------------------------------
// GENERATE CONNECTIVITY
<xsl:for-each select="//SMLLOWNL:Synapse">
	<xsl:variable name="src_size" select="../../SMLLOWNL:Neuron/@size"/>
	<xsl:variable name="dst_pop_name" select="../@dst_population"/>
	<xsl:variable name="dst_size" select="//SMLLOWNL:Neuron[@name=$dst_pop_name]/@size"/>
	<!-- XSLT to calculate the name of the memory array for the synapse is long - so pre-calculate  -->
	<xsl:choose>
		<xsl:when test="SMLNL:OneToOneConnection">
			<!-- To be handled natively, but for now: -->
			<!-- sanity check -->
			<xsl:if test="not($src_size=$dst_size)">
				<xsl:message terminate="yes">
Error: One to one connection has different source and destination population sizes
				</xsl:message>
			</xsl:if>
			<xsl:message terminate="yes">
Error: This should be a native type - so I'm not implementing it for now
			</xsl:message>
			<!-- zero memory -->
			<!---->	memset(<xsl:value-of select="$synapse_array_name"/>,<!---->
			<!---->0,<!---->
			<xsl:value-of select="concat('sizeof(float)*',$src_size,'*',$dst_size)"/>);
<!---->		<!-- write diagonal -->
			<!---->	for (int i = 0; i &lt; <xsl:value-of select="$src_size"/>; ++i) {
<!---->		<!----><xsl:text>		</xsl:text><xsl:value-of select="$synapse_array_name"/>[i*<xsl:value-of select="$src_size"/>+i] = <!-- G value goes here... -->1;
<!---->		<!---->	}
		</xsl:when>
		<xsl:when test="SMLNL:AllToAllConnection">
			<xsl:for-each select="SMLLOWNL:WeightUpdate/SMLNL:Property">
				<xsl:variable name="synapse_array_name">
					<xsl:if test="document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeGradedSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeLearningSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeSynapse'">
						<xsl:value-of select="concat('gpSynapse',position())"/>_<xsl:value-of select="translate(../../../../SMLLOWNL:Neuron/@name,' -','SH')"/>_to_<xsl:value-of select="translate(../../../@dst_population,' -','SH')"/>
					</xsl:if>
					<xsl:if test="not(document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeGradedSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeLearningSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeSynapse')">
						<xsl:value-of select="concat(@name ,'_WUSynapse',position())"/>_<xsl:value-of select="translate(../../../../SMLLOWNL:Neuron/@name,' -','SH')"/>_to_<xsl:value-of select="translate(../../../@dst_population,' -','SH')"/>
					</xsl:if>
				</xsl:variable>
				<xsl:if test="SMLNL:UniformDistribution">
					<!-- loop connections and fill in memory array -->
					//
<!---->				<!---->	for (int i = 0; i &lt; <xsl:value-of select="concat($src_size,'*',$dst_size)"/>; ++i) {
<!---->				<!----><xsl:text>		</xsl:text><xsl:value-of select="$synapse_array_name"/>[i] = <!---->
					<!---->uniformRand(<xsl:value-of select="SMLNL:UniformDistribution/@minimum"/>,<xsl:value-of select="SMLNL:UniformDistribution/@maximum"/>);			
<!---->				<!---->	}
<!---->			</xsl:if>
				<xsl:if test="SMLNL:NormalDistribution">
					<!-- loop connections and fill in memory array -->
					//
<!---->				<!---->	for (int i = 0; i &lt; <xsl:value-of select="concat($src_size,'*',$dst_size)"/>; ++i) {
<!---->				<!----><xsl:text>		</xsl:text><xsl:value-of select="$synapse_array_name"/>[i] = <!---->
					<!---->normalRand(<xsl:value-of select="SMLNL:NormalDistribution/@mean"/>,<xsl:value-of select="SMLNL:NormalDistribution/@variance"/>);			
<!---->				<!---->	}
<!---->			</xsl:if>
				<xsl:if test="SMLNL:PoissonDistribution">
					<!-- loop connections and fill in memory array -->
					//
<!---->				<!---->	for (int i = 0; i &lt; <xsl:value-of select="concat($src_size,'*',$dst_size)"/>; ++i) {
<!---->				<!----><xsl:text>		</xsl:text><xsl:value-of select="$synapse_array_name"/>[i] = poissonRand();			
<!---->				<!---->	}
<!---->			</xsl:if>
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="SMLNL:ConnectionList">
			<xsl:for-each select="SMLLOWNL:WeightUpdate/SMLNL:Property">
			<xsl:variable name="synapse_array_name">
				<xsl:if test="document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeGradedSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeLearningSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeSynapse'">
					<xsl:value-of select="concat('gpSynapse',position())"/>_<xsl:value-of select="translate(../../../../SMLLOWNL:Neuron/@name,' -','SH')"/>_to_<xsl:value-of select="translate(../../../@dst_population,' -','SH')"/>
				</xsl:if>
				<xsl:if test="not(document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeGradedSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeLearningSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeSynapse')">
					<xsl:value-of select="concat(@name ,'_WUSynapse',position())"/>_<xsl:value-of select="translate(../../../../SMLLOWNL:Neuron/@name,' -','SH')"/>_to_<xsl:value-of select="translate(../../../@dst_population,' -','SH')"/>
				</xsl:if>
			</xsl:variable>
			<!-- zero memory -->
			<xsl:if test="not(SMLNL:FixedValue)">
				<!---->	memset(<xsl:value-of select="$synapse_array_name"/>,<!---->
				<!---->0,<!---->
				<xsl:value-of select="concat('sizeof(float)*',$src_size,'*',$dst_size)"/>);
<!---->		</xsl:if>
			<xsl:if test="SMLNL:FixedValue">
				<!---->	memset(<xsl:value-of select="$synapse_array_name"/>,<!---->
				<!---->0,<!---->
				<xsl:value-of select="concat('ceil(',$src_size,'*',$dst_size,'/32.0f)')"/>);
<!---->		</xsl:if>
			<!-- fill in the array from the file, or XSLT -->
			<xsl:if test="../../SMLNL:ConnectionList/SMLNL:BinaryFile">
				<!-- binary file time - let's go! -->
				<xsl:if test="../../SMLNL:ConnectionList/SMLNL:BinaryFile/@explicit_delay_flag='0'">
				<!---->	vector &lt; conn &gt; connections;
<!---->			</xsl:if>
				<xsl:if test="../../SMLNL:ConnectionList/SMLNL:BinaryFile/@explicit_delay_flag='1'">
				<!---->	vector &lt; conn_with_delay &gt; connections;
<!---->			</xsl:if>
				<!---->	connections.resize(<xsl:value-of select="../../SMLNL:ConnectionList/SMLNL:BinaryFile/@num_connections"/>);
<!---->			<!---->	FILE * conn_file;
<!---->			<!---->	conn_file = fopen("<xsl:value-of select="../../SMLNL:ConnectionList/SMLNL:BinaryFile/@file_name"/>","rb");
<!---->			<!---->	if (!conn_file) {
<!---->			<!---->		cerr &lt;&lt; "Error opening binary connection file\n\n"; exit(-1);}
<!---->			<xsl:if test="../../SMLNL:ConnectionList/SMLNL:BinaryFile/@explicit_delay_flag='0'">
				<!---->	fread(&amp;connections[0], sizeof(conn), <xsl:value-of select="../../SMLNL:ConnectionList/SMLNL:BinaryFile/@num_connections"/>,conn_file);
<!---->			</xsl:if>
				<xsl:if test="../../SMLNL:ConnectionList/SMLNL:BinaryFile/@explicit_delay_flag='1'">
				<!---->	fread(&amp;connections[0], sizeof(conn_with_delay), <xsl:value-of select="../../SMLNL:ConnectionList/SMLNL:BinaryFile/@num_connections"/>,conn_file);
<!---->			</xsl:if>
				<xsl:if test="SMLNL:ValueList">
					<xsl:message terminate="yes">
Error: ValueList 'g' not implemented yet
					</xsl:message>
					<!-- loop connections and fill in memory array -->
					<!---->	for (int i = 0; i &lt; connections.size(); ++i) {
<!---->				<!----><xsl:text>		</xsl:text><xsl:value-of select="$synapse_array_name"/>[connections[i].dst*<xsl:value-of select="$src_size"/>+connections[i].src] = <!---->
					1 <!-- Need to read in file and do some crap here -->;			
<!---->				<!---->	}
<!---->			</xsl:if>
				<xsl:if test="SMLNL:UniformDistribution">
					<!-- loop connections and fill in memory array -->
					<!---->	for (int i = 0; i &lt; connections.size(); ++i) {
<!---->				<!----><xsl:text>		</xsl:text><xsl:value-of select="$synapse_array_name"/>[connections[i].dst*<xsl:value-of select="$src_size"/>+connections[i].src] = <!---->
					<!---->uniformRand(<xsl:value-of select="SMLNL:UniformDistribution/@minimum"/>,<xsl:value-of select="SMLNL:UniformDistribution/@maximum"/>);			
<!---->				<!---->	}
<!---->			</xsl:if>
				<xsl:if test="SMLNL:NormalDistribution">
					<!-- loop connections and fill in memory array -->
					<!---->	for (int i = 0; i &lt; connections.size(); ++i) {
<!---->				<!----><xsl:text>		</xsl:text><xsl:value-of select="$synapse_array_name"/>[connections[i].dst*<xsl:value-of select="$src_size"/>+connections[i].src] = <!---->
					<!---->normalRand(<xsl:value-of select="SMLNL:NormalDistribution/@mean"/>,<xsl:value-of select="SMLNL:NormalDistribution/@variance"/>);			
<!---->				<!---->	}
<!---->			</xsl:if>
				<xsl:if test="SMLNL:PoissonDistribution">
					<!-- loop connections and fill in memory array -->
					<!---->	for (int i = 0; i &lt; connections.size(); ++i) {
<!---->				<!----><xsl:text>		</xsl:text><xsl:value-of select="$synapse_array_name"/>[connections[i].dst*<xsl:value-of select="$src_size"/>+connections[i].src] = poissonRand();			
<!---->				<!---->	}
<!---->			</xsl:if>
				<xsl:if test="SMLNL:FixedValue">
					<!-- loop connections and fill in memory array -->
					<!---->	for (int i = 0; i &lt; connections.size(); ++i) {
					<!---->		setB(<xsl:value-of select="$synapse_array_name"/>[floor(float(connections[i].dst*<xsl:value-of select="$src_size"/>+connections[i].src)/64.0)],(connections[i].dst*<xsl:value-of select="$src_size"/>+connections[i].src)%64);			
<!---->				<!---->	}
<!---->			</xsl:if>

			</xsl:if>
			<xsl:if test="count(../../SMLNL:ConnectionList/SMLNL:Connection) > 0">
				<xsl:variable name="curr_prop" select="."/>
				<!-- non-binary list - expand out -->
				<xsl:if test="count(../../SMLNL:ConnectionList/SMLNL:Connection) > 1000">
					<xsl:message terminate="no">
Warning: Large connection list detected, code generation will be inefficient - consider using the BinaryFile tag
					</xsl:message>
				</xsl:if>
				<xsl:if test="SMLNL:ValueList">
						<!-- loop connections and fill in memory array -->
						<xsl:message terminate="yes">
Error: ValueList 'g' not implemented yet
					</xsl:message>
						<!---->	for (int i = 0; i &lt; connections.size(); ++i) {
<!---->					<!----><xsl:text>		</xsl:text><xsl:value-of select="$synapse_array_name"/>[connections[i].src*<xsl:value-of select="$dst_size"/>+connections[i].dst] = <!---->
						1 <!-- Need to read in file and do some crap here -->;			
<!---->					<!---->	}
<!---->			</xsl:if>
				<xsl:if test="SMLNL:UniformDistribution">
					<!-- SET THE SEED -->

					<!---->	rngData.seed = <xsl:value-of select="SMLLOWNL:WeightUpdate/SMLNL:Property[@name='g']/SMLNL:UniformDistribution/@seed"/>;
<!---->				<xsl:for-each select="SMLNL:ConnectionList/SMLNL:Connection">
<!---->				<!---->	<xsl:value-of select="$synapse_array_name"/>[<xsl:value-of select="number(@src_neuron)*number($dst_size)+number(@dst_neuron)"/>] = uniformRand(<xsl:value-of select="../../SMLLOWNL:WeightUpdate/SMLNL:Property[@name='g']/SMLNL:UniformDistribution/@minimum"/>,<xsl:value-of select="../../SMLLOWNL:WeightUpdate/SMLNL:Property[@name='g']/SMLNL:UniformDistribution/@maximum"/>);
printf("value of w = %f\n", <xsl:value-of select="$synapse_array_name"/>[<xsl:value-of select="number(@src_neuron)*number($dst_size)+number(@dst_neuron)"/>]);
					</xsl:for-each>
<!---->			</xsl:if>
				<xsl:if test="SMLNL:NormalDistribution">
					<xsl:for-each select="../../SMLNL:ConnectionList/SMLNL:Connection">
<!---->				<!---->	<xsl:value-of select="$synapse_array_name"/>[<xsl:value-of select="number(@src_neuron)*number($dst_size)+number(@dst_neuron)"/>] = normalRand(<xsl:value-of select="$curr_prop/SMLNL:NormalDistribution/@mean"/>,<xsl:value-of select="$curr_prop/SMLNL:NormalDistribution/@variance"/>);
					</xsl:for-each>
<!---->			</xsl:if>
				<xsl:if test="SMLNL:PoissonDistribution">
					<xsl:for-each select="../../SMLNL:ConnectionList/SMLNL:Connection">
<!---->				<!---->	<xsl:value-of select="$synapse_array_name"/>[<xsl:value-of select="number(@src_neuron)*number($dst_size)+number(@dst_neuron)"/>] = poissonRand();
					</xsl:for-each>
<!---->			</xsl:if>
				<xsl:if test="SMLNL:FixedValue">
					<xsl:for-each select="../../SMLNL:ConnectionList/SMLNL:Connection">
<!---->				<!---->	setB(<xsl:value-of select="$synapse_array_name"/>[(int) floor(float(<xsl:value-of select="number(@src_neuron)*number($dst_size)+number(@dst_neuron)"/>)/32.0)],(<xsl:value-of select="number(@dst_neuron)*number($src_size)+number(@src_neuron)"/>)%32);
					</xsl:for-each>
<!---->			</xsl:if>
			</xsl:if>		
			</xsl:for-each>		
		</xsl:when>
		<xsl:when test="SMLNL:FixedProbabilityConnection">
			<xsl:for-each select="SMLLOWNL:WeightUpdate/SMLNL:Property">
			<xsl:variable name="synapse_array_name">
				<xsl:if test="document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeGradedSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeLearningSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeSynapse'">
					<xsl:value-of select="concat('gpSynapse',position())"/>_<xsl:value-of select="translate(../../../../SMLLOWNL:Neuron/@name,' -','SH')"/>_to_<xsl:value-of select="translate(../../../@dst_population,' -','SH')"/>
				</xsl:if>
				<xsl:if test="not(document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeGradedSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeLearningSynapse' or document(../@url)//SMLCL:ComponentClass/@name='GeNNNativeSynapse')">
					<xsl:value-of select="concat(@name ,'_WUSynapse',position())"/>_<xsl:value-of select="translate(../../../../SMLLOWNL:Neuron/@name,' -','SH')"/>_to_<xsl:value-of select="translate(../../../@dst_population,' -','SH')"/>
				</xsl:if>
			</xsl:variable>
			<xsl:if test="SMLNL:ValueList">
					<!-- loop connections and fill in memory array -->
					<xsl:message terminate="yes">
Error: ValueList 'g' not implemented yet
				</xsl:message>
					<!---->	for (int i = 0; i &lt; connections.size(); ++i) {
<!---->				<!----><xsl:text>		</xsl:text><xsl:value-of select="$synapse_array_name"/>[connections[i].src*<xsl:value-of select="$dst_size"/>+connections[i].dst] = <!---->
					1 <!-- Need to read in file and do some crap here -->;			
<!---->				<!---->	}
<!---->		</xsl:if>
			<xsl:if test="SMLNL:UniformDistribution">
				<!---->	for (int i = 0; i &lt; <xsl:value-of select="$src_size"/>; ++i) {	
<!---->			<!---->		for (int j = 0; j &lt; <xsl:value-of select="$dst_size"/>; ++j) {
<!---->			<!---->			if (UNI &lt; <xsl:value-of select="../../SMLNL:FixedProbabilityConnection/@probability"/>) {
<!---->			<!----><xsl:text>				</xsl:text><xsl:value-of select="$synapse_array_name"/>[i*<xsl:value-of select="$dst_size"/>+j] = uniformRand(<xsl:value-of select="SMLNL:UniformDistribution/@minimum"/>,<xsl:value-of select="SMLNL:UniformDistribution/@maximum"/>);	
<!---->			<!---->			} else {
<!---->			<!----><xsl:text>				</xsl:text><xsl:value-of select="$synapse_array_name"/>[i*<xsl:value-of select="$dst_size"/>+j] = 0;	
<!---->			<!---->			} 
<!---->			<!---->		}
<!---->			<!---->	}	
<!---->		</xsl:if>
			<xsl:if test="SMLNL:NormalDistribution">
				<!-- loop connections and fill in memory array -->
				<!---->	for (int i = 0; i &lt; <xsl:value-of select="$src_size"/>; ++i) {	
<!---->			<!---->		for (int j = 0; j &lt; <xsl:value-of select="$dst_size"/>; ++j) {
<!---->			<!---->			if (UNI &lt; <xsl:value-of select="../../SMLNL:FixedProbabilityConnection/@probability"/>) {
<!---->			<!----><xsl:text>				</xsl:text><xsl:value-of select="$synapse_array_name"/>[i*<xsl:value-of select="$dst_size"/>+j] = normalRand(<xsl:value-of select="SMLNL:NormalDistribution/@mean"/>,<xsl:value-of select="SMLNL:NormalDistribution/@variance"/>);	
<!---->			<!---->			} else {
<!---->			<!----><xsl:text>				</xsl:text><xsl:value-of select="$synapse_array_name"/>[i*<xsl:value-of select="$dst_size"/>+j] = 0;	
<!---->			<!---->			} 
<!---->			<!---->		}
<!---->			<!---->	}	
<!---->		</xsl:if>
			<xsl:if test="SMLNL:PoissonDistribution">
					<!-- loop connections and fill in memory array -->
				<xsl:message terminate="yes">
Error: PoissonDistribution 'g' not implemented yet
				</xsl:message>
				<!---->	for (int i = 0; i &lt; <xsl:value-of select="$src_size"/>; ++i) {	
<!---->			<!---->		for (int j = 0; j &lt; <xsl:value-of select="$dst_size"/>; ++j) {
<!---->			<!---->			if (UNI &lt; <xsl:value-of select="../../SMLNL:FixedProbabilityConnection/@probability"/>) {
<!---->			<!----><xsl:text>				</xsl:text><xsl:value-of select="$synapse_array_name"/>[i*<xsl:value-of select="$dst_size"/>+j] = uniformRand(<xsl:value-of select="SMLLOWNL:WeightUpdate/SMLNL:Property[@name='g']/SMLNL:UniformDistribution/@minimum"/>,<xsl:value-of select="SMLLOWNL:WeightUpdate/SMLNL:Property[@name='g']/SMLNL:UniformDistribution/@maximum"/>);	
<!---->			<!---->			} else {
<!---->			<!----><xsl:text>				</xsl:text><xsl:value-of select="$synapse_array_name"/>[i*<xsl:value-of select="$dst_size"/>+j] = 0;	
<!---->			<!---->			} 
<!---->			<!---->		}
<!---->			<!---->	}	
<!---->		</xsl:if>
			<xsl:if test="SMLNL:FixedValue">
				<!---->	for (int i = 0; i &lt; <xsl:value-of select="$src_size"/>; ++i) {	
<!---->			<!---->		for (int j = 0; j &lt; <xsl:value-of select="$dst_size"/>; ++j) {
<!---->			<!---->			if (UNI &lt; <xsl:value-of select="../../SMLNL:FixedProbabilityConnection/@probability"/>) {
<!---->			<!---->				setB(<xsl:value-of select="$synapse_array_name"/>[(int) floor(float(i*<xsl:value-of select="$dst_size"/>+j)/32.0)],(i*<xsl:value-of select="$dst_size"/>+j)%32);	
<!---->			<!---->			} else {
<!---->			<!---->				delB(<xsl:value-of select="$synapse_array_name"/>[(int) floor(float(i*<xsl:value-of select="$dst_size"/>+j)/32.0)],(i*<xsl:value-of select="$dst_size"/>+j)%32);	
<!---->			<!---->			} 
<!---->			<!---->		}
<!---->			<!---->	}	
<!---->		</xsl:if>
			</xsl:for-each>
		</xsl:when>
		<xsl:otherwise>
			<xsl:message terminate="yes">
Error: Unrecognised connection type
			</xsl:message>
		</xsl:otherwise>
	</xsl:choose>
</xsl:for-each>

// ALLOCATE MEMORY FOR POISSON
	
	<!-- HACK FOR NOW -->
	<xsl:for-each select="//SMLLOWNL:Neuron[@url='GeNNNativePoisson.xml']"> <!-- FOR EACH POISSON SOURCE -->
		<!-- Fill an array size num_neurons with the rate value -->
		// add data to array
		<xsl:choose>
		<xsl:when test="./SMLNL:Property[@name='therate']/SMLNL:FixedValue">
		unsigned int rates<xsl:value-of select="translate(@name,' -','SH')"/>[<xsl:value-of select="@size"/>];<!---->
		for (unsigned int i = 0; i &lt; <xsl:value-of select="@size"/>; ++i)<!---->
			rates<xsl:value-of select="translate(@name,' -','SH')"/>[i] = <xsl:value-of select="./SMLNL:Property[@name='therate']/SMLNL:FixedValue/@value"/>;<!---->
		</xsl:when>
		<xsl:when test="./SMLNL:Property[@name='therate']/SMLNL:UniformDistribution">
		unsigned int rates<xsl:value-of select="translate(@name,' -','SH')"/>[<xsl:value-of select="@size"/>];<!---->
		for (unsigned int i = 0; i &lt; <xsl:value-of select="@size"/>; ++i)<!---->
			rates<xsl:value-of select="translate(@name,' -','SH')"/>[i] = uniformRand(<xsl:value-of select="./SMLNL:Property[@name='therate']/SMLNL:UniformDistribution/@minimum"/>,<xsl:value-of select="./SMLNL:Property[@name='therate']/SMLNL:UniformDistribution/@maximum"/>);<!---->
		</xsl:when>
		<xsl:when test="./SMLNL:Property[@name='therate']/SMLNL:NormalDistribution">
		unsigned int rates<xsl:value-of select="translate(@name,' -','SH')"/>[<xsl:value-of select="@size"/>];<!---->
		for (unsigned int i = 0; i &lt; <xsl:value-of select="@size"/>; ++i)<!---->
			rates<xsl:value-of select="translate(@name,' -','SH')"/>[i] = normalRand(<xsl:value-of select="./SMLNL:Property[@name='therate']/SMLNL:NormalDistribution/@mean"/>,<xsl:value-of select="./SMLNL:Property[@name='therate']/SMLNL:NormalDistribution/@variance"/>);<!---->
		</xsl:when>
		<xsl:when test="./SMLNL:Property[@name='therate']/SMLNL:PoissonDistribution">
		unsigned int rates<xsl:value-of select="translate(@name,' -','SH')"/>[<xsl:value-of select="@size"/>];<!---->
		for (unsigned int i = 0; i &lt; <xsl:value-of select="@size"/>; ++i)<!---->
			rates<xsl:value-of select="translate(@name,' -','SH')"/>[i] = poissonRand();<!---->
		</xsl:when>
		<xsl:when test="./SMLNL:Property[@name='therate']/SMLNL:ValueList">
		unsigned int rates<xsl:value-of select="translate(@name,' -','SH')"/> [] = {<!---->
			<!-- PRETTY SURE THIS WILL WORK - BUT IT IS SLOW AND I DON'T LIKE IT -->
			<xsl:for-each select="./SMLNL:Property[@name='therate']/SMLNL:ValueList/SML:Value">
				<xsl:variable name="index" select="position()-1"/>
				<xsl:for-each select="./SMLNL:Property[@name='therate']/SMLNL:ValueList/SML:Value">
					<xsl:if test="@index=$index">
						<xsl:value-of select="concat(@value,',')"/>
					</xsl:if>
				</xsl:for-each>				
			</xsl:for-each>}
<!---->	</xsl:when>	
		<xsl:otherwise>
			<xsl:message terminate="yes">
Error: Native Poisson parameter 'therate' not found or undefined 
			</xsl:message>
		</xsl:otherwise>
		</xsl:choose>	
      	fprintf(stderr, "# %d %d %d %d \n", rates<xsl:value-of select="translate(@name,' -','SH')"/>[0],rates<xsl:value-of select="translate(@name,' -','SH')"/>[1],rates<xsl:value-of select="translate(@name,' -','SH')"/>[2],rates<xsl:value-of select="translate(@name,' -','SH')"/>[3]);

		// copy to GPU
		int size = sizeof(unsigned int)*<xsl:value-of select="@size"/>;
		unsigned int * d_rates<xsl:value-of select="translate(@name,' -','SH')"/>;
		if (which == GPU) {
			CHECK_CUDA_ERRORS((cudaMalloc((void**) &amp;d_rates<xsl:value-of select="translate(@name,' -','SH')"/>, size)));
			CHECK_CUDA_ERRORS((cudaMemcpy(d_rates<xsl:value-of select="translate(@name,' -','SH')"/>, rates<xsl:value-of select="translate(@name,' -','SH')"/>, size, cudaMemcpyHostToDevice))); 
		}
	</xsl:for-each> <!-- END FOR EACH POISSON SOURCE -->

  
// INIT CODE
  //initGRaw();
  if (which == CPU) {
    //theRates= baserates;
  }
  if (which == GPU) {
    copyGToDevice(); 
    copyStateToDevice();
    //theRates= d_baserates;
  }         // this includes copying g's for the GPU version

  fprintf(stderr, "# neuronal circuitry built, start computation ... \n\n");

  //------------------------------------------------------------------
  // output general parameters to output file and start the simulation

  fprintf(stderr, "# We are running with fixed time step %f \n", DT);
  fprintf(stderr, "# initial wait time execution ... \n");

 t= 0.0;
 unsigned int offset = 0;
 float output [10];
 void *devPtr;
 FILE * output_file;
 output_file = fopen("/home/esin/log1.dat","w");
 if (!output_file)
 	cerr &lt;&lt; "Error creating log file!\n\n";
 
 timer.startTimer();	
 for (int i= 0; i &lt; <xsl:value-of select="number($experiment_file//SMLEX:Simulation/@duration)*1000.0 div number($experiment_file//@dt)"/>; i++) {
      
    if (which == GPU) {
       stepTimeGPU(<!-- THIS IS A LITTLE HACKY AS IT USES THE FILE URL WHICH COULD CHANGE... BUT WE'LL REDO THIS FOR INPUTS ANYWAY... -->
       	<xsl:for-each select="//SMLLOWNL:Neuron[@url='GeNNNativePoisson.xml']">
       		<!---->d_rates<xsl:value-of select="translate(@name,' -','SH')"/>,offset,<!---->
       	</xsl:for-each>
       <!----> t);       	
		if (!(i % 1)) {
     		//cudaGetSymbolAddress(&amp;devPtr, d_VPopulation);
      		//CHECK_CUDA_ERRORS((cudaMemcpy(output, d_V_NBPopulation, 10*sizeof(float), cudaMemcpyDeviceToHost)));
			float out2;
      		//CHECK_CUDA_ERRORS((cudaMemcpy(&amp;out2, d_V_NBPopulationS2, 1*sizeof(float), cudaMemcpyDeviceToHost)));
			float out3 = 0;
      		//fprintf(output_file, "%f %f %f %f %f %f\n", t,output[0],output[1],output[2], out2, out3);
      		//cout &lt;&lt; output[0] &lt;&lt; " " &lt;&lt; output[1] &lt;&lt; " " &lt;&lt; output[2] &lt;&lt; " " &lt;&lt; output[3] &lt;&lt; endl;
      	}
	}
    if (which == CPU)
       stepTimeCPU(<!-- THIS IS A LITTLE HACKY AS IT USES THE FILE URL WHICH COULD CHANGE... BUT WE'LL REDO THIS FOR INPUTS ANYWAY... -->
       	<xsl:for-each select="//SMLLOWNL:Neuron[@url='GeNNNativePoisson.xml']">
       		<!---->rates<xsl:value-of select="translate(@name,' -','SH')"/>,offset,<!---->
       	</xsl:for-each>
       	<!----> t);
    t+= DT;
    //fprintf(stderr, "# one time step complete ... \n\n");
    
    
  }
  timer.stopTimer();
  fprintf(stderr, "Time taken = %f \n", timer.getElapsedTime());

  return 0;
}

</xsl:for-each> <!-- LEAVE NETWORK FILE-->

</xsl:template>

</xsl:stylesheet>
